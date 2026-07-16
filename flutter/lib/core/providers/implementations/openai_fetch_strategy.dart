import '../../models/provider_cost.dart';
import '../../models/provider_identity.dart';
import '../../models/rate_window.dart';
import '../../models/usage_snapshot.dart';
import '../provider_fetch_strategy.dart';
import '../http_client.dart';

/// Fetches OpenAI organization usage from the costs/completions endpoints,
/// with a legacy credit-grants fallback for unscoped keys.
///
/// Ported from `OpenAIAPIUsageFetcher` in
/// `Sources/CodexBarCore/Providers/OpenAI/`. Produces a [UsageSnapshot] whose
/// `providerCost` reflects the rolling 30-day spend; the legacy balance path
/// additionally produces a `primary` [RateWindow].
class OpenAIFetchStrategy extends ProviderFetchStrategy {
  OpenAIFetchStrategy({ProviderHttpClient? http, int historyDays = 30})
      : _http = http ?? ProviderHttpClient(),
        _historyDays = historyDays.clamp(1, 365);

  final ProviderHttpClient _http;
  final int _historyDays;

  static const _base = 'https://api.openai.com';

  @override
  String get id => 'openai-api';

  @override
  FetchStrategyKind get kind => FetchStrategyKind.apiToken;

  @override
  bool isAvailable(ProviderFetchContext context) =>
      context.apiKey != null && context.apiKey!.isNotEmpty;

  @override
  Future<ProviderFetchAttempt> fetch(ProviderFetchContext context) async {
    final key = context.apiKey!;
    final headers = {'Authorization': 'Bearer $key'};
    final now = DateTime.now().toUtc();
    final start = now.subtract(Duration(days: _historyDays));
    final startSec = start.millisecondsSinceEpoch ~/ 1000;
    final endSec = now.millisecondsSinceEpoch ~/ 1000;
    final project = context.projectID;

    // The /organization/costs endpoint requires an Admin key or a project key
    // carrying the api.usage.read scope. Project keys (e.g. `sk-mcg`) without
    // that scope are rejected with 403 — in that case we fall back to the
    // legacy credit-grants endpoint (mirrors the Swift credential routing in
    // OpenAIAPIUsageFetcher: `allowsLegacyBalanceFallback`).
    double costUSD = 0;
    final lineItems = <String, double>{};
    ProviderFetchError? costsError;

    try {
      String? page;
      var pages = 0;
      while (pages < 100) {
        final body = await _http.getJson(
          _base,
          '/v1/organization/costs',
          query: {
            'start_time': '$startSec',
            'end_time': '$endSec',
            'bucket_width': '1d',
            'limit': '31',
            'group_by': 'line_item',
            if (project != null) 'project_ids': project,
            if (page != null) 'page': page,
          },
          headers: headers,
        );
        final data = (body['data'] as List?) ?? [];
        for (final bucket in data) {
          final results = (bucket['results'] as List?) ?? [];
          for (final r in results) {
            final amount = (r['amount'] as Map?)?['value'];
            final v = _asDouble(amount);
            costUSD += v;
            final name = (r['line_item'] as String?) ?? 'Other';
            lineItems[name] = (lineItems[name] ?? 0) + v;
          }
        }
        final hasMore = body['has_more'] == true;
        final next = body['next_page'];
        if (!hasMore || next == null) break;
        page = next.toString();
        pages++;
      }
    } on ProviderFetchError catch (e) {
      // Costs endpoint rejected the key — remember the error so we can try the
      // legacy balance endpoint and, if that also fails, surface this.
      costsError = e;
    }

    // If costs failed with a credential rejection, try the legacy credit-grants
    // endpoint before giving up. This is how project keys (sk-mcg) without the
    // usage scope still surface a balance.
    final isCredentialRejected =
        costsError is UnauthorizedError || costsError is ForbiddenError;
    RateWindow? primary;
    double? creditLimit;
    double? creditUsed;
    DateTime? creditResetsAt;
    ProviderFetchError? balanceError;

    if (isCredentialRejected) {
      try {
        final grants = await _http.getJson(
          _base,
          '/v1/dashboard/billing/credit_grants',
          headers: headers,
        );
        final totalGranted = _asDouble(grants['total_granted']);
        final totalUsed = _asDouble(grants['total_used']);
        final totalAvailable = _asDouble(grants['total_available']);
        final grantsList = (grants['grants'] as Map?)?['data'] as List?;
        DateTime? nextExpiry;
        if (grantsList != null) {
          for (final g in grantsList) {
            final exp = g['expires_at'];
            if (exp is num) {
              final dt = DateTime.fromMillisecondsSinceEpoch(
                  exp.toInt() * 1000, isUtc: true);
              if (nextExpiry == null || dt.isBefore(nextExpiry)) nextExpiry = dt;
            }
          }
        }
        final usedPercent = totalGranted > 0
            ? (totalUsed / totalGranted * 100).clamp(0, 100)
            : (totalAvailable > 0 ? 0.0 : 100.0);
        primary = RateWindow(
          usedPercent: usedPercent.toDouble(),
          windowMinutes: null,
          resetsAt: nextExpiry,
          resetDescription: '\$${totalAvailable.toStringAsFixed(2)} available',
        );
        creditLimit = totalGranted;
        creditUsed = totalUsed;
        creditResetsAt = nextExpiry;
      } on ProviderFetchError catch (e) {
        // Legacy balance also rejected — surface the original costs error below.
        balanceError = e;
      }
    }

    // If costs failed AND the balance fallback didn't produce a snapshot,
    // surface the error. Prefer the most informative one.
    if (costsError != null && primary == null) {
      return ProviderFetchFailure(balanceError ?? costsError);
    }

    return ProviderFetchSuccess(
      snapshotJson: UsageSnapshot(
        primary: primary,
        providerCost: ProviderCostSnapshot(
          used: creditUsed ?? costUSD,
          limit: creditLimit ?? 0,
          currencyCode: 'USD',
          period: 'Last $_historyDays days',
          resetsAt: creditResetsAt,
          updatedAt: now,
        ),
        updatedAt: now,
        identity: ProviderIdentitySnapshot(
          loginMethod: project == null ? 'API key' : 'API key (project)',
        ),
      ).toJson(),
    );
  }
}

double _asDouble(Object? v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}
