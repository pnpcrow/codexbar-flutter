import '../../models/provider_cost.dart';
import '../../models/provider_identity.dart';
import '../../models/usage_snapshot.dart';
import '../provider_fetch_strategy.dart';
import '../http_client.dart';

/// Fetches Anthropic (Claude) organization usage from the cost_report and
/// messages usage_report endpoints.
///
/// Ported from `ClaudeAdminAPIUsageFetcher` in
/// `Sources/CodexBarCore/Providers/Claude/`. Anthropic cost `amount` is a
/// decimal string in **lowest USD units**, so values are divided by 100.
/// Produces a [UsageSnapshot] whose `providerCost` reflects the rolling
/// 30-day spend (no rate-limit percent for this path).
class AnthropicFetchStrategy extends ProviderFetchStrategy {
  AnthropicFetchStrategy({ProviderHttpClient? http, int historyDays = 30})
      : _http = http ?? ProviderHttpClient(),
        _historyDays = historyDays.clamp(1, 365);

  final ProviderHttpClient _http;
  final int _historyDays;

  static const _base = 'https://api.anthropic.com';

  @override
  String get id => 'anthropic-admin-api';

  @override
  FetchStrategyKind get kind => FetchStrategyKind.apiToken;

  @override
  bool isAvailable(ProviderFetchContext context) =>
      context.apiKey != null && context.apiKey!.isNotEmpty;

  @override
  Future<ProviderFetchAttempt> fetch(ProviderFetchContext context) async {
    final key = context.apiKey!;
    final headers = {
      'x-api-key': key,
      'anthropic-version': '2023-06-01',
    };
    final now = DateTime.now().toUtc();
    final start = now.subtract(Duration(days: _historyDays));
    final startStr = start.toIso8601String();
    final endStr = now.toIso8601String();

    try {
      // Cost report (single page, 31 buckets max).
      final costBody = await _http.getJson(
        _base,
        '/v1/organizations/cost_report',
        query: {
          'starting_at': startStr,
          'ending_at': endStr,
          'bucket_width': '1d',
          'limit': '${_historyDays + 1}',
          'group_by[]': 'description',
        },
        headers: headers,
      );

      double costUSD = 0;
      final breakdown = <String, double>{};
      for (final bucket in (costBody['data'] as List?) ?? []) {
        for (final r in (bucket['results'] as List?) ?? []) {
          // Anthropic amount is in lowest USD units (cents-equivalent).
          final usd = _asDouble(r['amount']) / 100;
          costUSD += usd;
          final name = (r['description'] as String?) ??
              (r['cost_type'] as String?) ??
              'Other';
          breakdown[name] = (breakdown[name] ?? 0) + usd;
        }
      }

      return ProviderFetchSuccess(
        snapshotJson: UsageSnapshot(
          providerCost: ProviderCostSnapshot(
            used: costUSD,
            limit: 0,
            currencyCode: 'USD',
            period: 'Last $_historyDays days',
            updatedAt: now,
          ),
          updatedAt: now,
          identity: ProviderIdentitySnapshot(loginMethod: 'Admin API'),
        ).toJson(),
      );
    } on ProviderFetchError catch (e) {
      return ProviderFetchFailure(e);
    }
  }
}

double _asDouble(Object? v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}
