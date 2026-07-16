import '../../models/provider_identity.dart';
import '../../models/rate_window.dart';
import '../../models/usage_snapshot.dart';
import '../provider_fetch_strategy.dart';
import '../http_client.dart';

/// Fetches OpenRouter usage from the `/credits` (primary) and `/key`
/// (optional enrichment) endpoints.
///
/// Ported from `OpenRouterUsageFetcher` in
/// `Sources/CodexBarCore/Providers/OpenRouter/`. Produces a [UsageSnapshot]
/// whose `openRouterUsage` carries the credits/key detail and whose `primary`
/// window reflects the key-level quota when available.
class OpenRouterFetchStrategy extends ProviderFetchStrategy {
  OpenRouterFetchStrategy({ProviderHttpClient? http, String? baseURL})
      : _http = http ?? ProviderHttpClient(),
        _baseURL = baseURL ?? 'https://openrouter.ai/api/v1';

  final ProviderHttpClient _http;
  final String _baseURL;

  @override
  String get id => 'openrouter-api';

  @override
  FetchStrategyKind get kind => FetchStrategyKind.apiToken;

  @override
  bool isAvailable(ProviderFetchContext context) =>
      context.apiKey != null && context.apiKey!.isNotEmpty;

  @override
  Future<ProviderFetchAttempt> fetch(ProviderFetchContext context) async {
    final key = context.apiKey!;
      final referer = context.extraHeaders['HTTP-Referer'];
      final title = context.extraHeaders['X-Title'];
      final headers = <String, String>{
        'Authorization': 'Bearer $key',
        if (referer != null) 'HTTP-Referer': referer,
        if (title != null) 'X-Title': title,
      };

    try {
      final credits = await _http.getJson(
        context.baseURLOverride ?? _baseURL,
        '/credits',
        headers: headers,
        timeout: const Duration(seconds: 15),
      );
      final data = (credits['data'] as Map<String, dynamic>?) ?? {};
      final totalCredits = _asDouble(data['total_credits']);
      final totalUsage = _asDouble(data['total_usage']);
      final balance = (totalCredits - totalUsage).clamp(0, double.infinity);
      final creditsUsedPercent = totalCredits > 0
          ? (totalUsage / totalCredits * 100).clamp(0, 100)
          : 0.0;

      // Key quota enrichment is best-effort and does not block credits.
      Map<String, dynamic>? keyData;
      try {
        final keyResponse = await _http.getJson(
          context.baseURLOverride ?? _baseURL,
          '/key',
          headers: headers,
          timeout: const Duration(seconds: 3),
        );
        keyData = (keyResponse['data'] as Map<String, dynamic>?) ?? {};
      } on ProviderFetchError {
        keyData = null;
      }

      final keyLimit = keyData == null ? null : _asDouble(keyData['limit']);
      final keyUsage = keyData == null ? null : _asDouble(keyData['usage']);
      final keyUsedPercent =
          (keyLimit != null && keyLimit > 0 && keyUsage != null && keyUsage >= 0)
              ? (keyUsage / keyLimit * 100).clamp(0, 100).toDouble()
              : null;

      final now = DateTime.now().toUtc();
      return ProviderFetchSuccess(
        snapshotJson: UsageSnapshot(
          primary: keyUsedPercent == null
              ? null
              : RateWindow(
                  usedPercent: keyUsedPercent,
                  windowMinutes: null,
                  resetsAt: null,
                  resetDescription: keyLimit != null
                      ? '\$${(keyLimit - (keyUsage ?? 0)).toStringAsFixed(2)} key budget left'
                      : null,
                ),
          updatedAt: now,
          identity: ProviderIdentitySnapshot(
            loginMethod: 'Balance: \$${balance.toStringAsFixed(2)}',
          ),
          openRouterUsage: {
            'totalCredits': totalCredits,
            'totalUsage': totalUsage,
            'balance': balance,
            'usedPercent': creditsUsedPercent,
            'keyLimit': keyLimit,
            'keyUsage': keyUsage,
            'updatedAt': now.toIso8601String(),
          },
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
