import '../../models/provider_identity.dart';
import '../../models/rate_window.dart';
import '../../models/usage_snapshot.dart';
import '../provider_fetch_strategy.dart';
import '../http_client.dart';

/// Fetches DeepSeek balance (and optional monthly usage) from the user/balance
/// and platform usage endpoints.
///
/// Ported from `DeepSeekUsageFetcher` in
/// `Sources/CodexBarCore/Providers/DeepSeek/`. DeepSeek has no real usage
/// percentage; one is synthesized from the balance state (0% when funds
/// remain, 100% when exhausted).
class DeepSeekFetchStrategy extends ProviderFetchStrategy {
  DeepSeekFetchStrategy({ProviderHttpClient? http})
      : _http = http ?? ProviderHttpClient();

  final ProviderHttpClient _http;

  static const _balanceBase = 'https://api.deepseek.com';

  @override
  String get id => 'deepseek-api';

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

    try {
      final balanceBody = await _http.getJson(
        _balanceBase,
        '/user/balance',
        headers: headers,
      );
      final isAvailable = balanceBody['is_available'] as bool? ?? true;
      final infos = (balanceBody['balance_infos'] as List?) ?? [];

      double totalBalance = 0;
      double grantedBalance = 0;
      double toppedUpBalance = 0;
      String currency = 'USD';

      if (infos.isNotEmpty) {
        // Prefer a USD row with a positive balance; else first positive; else
        // first USD; else first row.
        final infoMaps = infos.cast<Map<String, dynamic>>();
        Map<String, dynamic>? chosen;
        chosen = _firstWhere(infoMaps, (i) =>
            (i['currency'] as String?) == 'USD' && _asDouble(i['total_balance']) > 0);
        chosen ??= _firstWhere(infoMaps, (i) => _asDouble(i['total_balance']) > 0);
        chosen ??= _firstWhere(infoMaps, (i) => (i['currency'] as String?) == 'USD');
        chosen ??= infoMaps.first;
        totalBalance = _asDouble(chosen['total_balance']);
        grantedBalance = _asDouble(chosen['granted_balance']);
        toppedUpBalance = _asDouble(chosen['topped_up_balance']);
        currency = (chosen['currency'] as String?) ?? 'USD';
      }

      final double usedPercent;
      final String resetDescription;
      if (totalBalance <= 0) {
        usedPercent = 100;
        resetDescription = '\$0.00 — add credits at platform.deepseek.com';
      } else if (!isAvailable) {
        usedPercent = 100;
        resetDescription = 'Balance unavailable for API calls';
      } else {
        usedPercent = 0;
        resetDescription =
            '\$$totalBalance (Paid: \$$toppedUpBalance / Granted: \$$grantedBalance)';
      }

      return ProviderFetchSuccess(
        snapshotJson: UsageSnapshot(
          primary: RateWindow(
            usedPercent: usedPercent,
            windowMinutes: null,
            resetsAt: null,
            resetDescription: resetDescription,
          ),
          updatedAt: now,
          identity: ProviderIdentitySnapshot(loginMethod: 'API key'),
          deepseekUsage: {
            'totalBalance': totalBalance,
            'grantedBalance': grantedBalance,
            'toppedUpBalance': toppedUpBalance,
            'currency': currency,
            'isAvailable': isAvailable,
            'updatedAt': now.toIso8601String(),
          },
        ).toJson(),
      );
    } on ProviderFetchError catch (e) {
      return ProviderFetchFailure(e);
    }
  }
}

Map<String, dynamic>? _firstWhere(
  List<Map<String, dynamic>> list,
  bool Function(Map<String, dynamic>) test,
) {
  for (final e in list) {
    if (test(e)) return e;
  }
  return null;
}

double _asDouble(Object? v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}
