

import 'package:http/http.dart' as http;

import '../../auth/cli_token_resolver.dart';
import '../../models/fetch_kind.dart';
import '../../models/fetch_result.dart';
import '../../models/provider_identity.dart';
import '../../models/rate_window.dart';
import '../../models/usage_provider.dart';
import '../../models/usage_snapshot.dart';
import '../fetch_strategy.dart';

/// Groq API fetch strategy.
/// Uses GROQ_API_KEY to fetch usage/rate-limit data.
class GroqAPIFetchStrategy extends FetchStrategy {
  @override
  String get id => 'groq.api';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.apiToken;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    final resolver = CLITokenResolver();
    return resolver.resolve(UsageProvider.groq, env: context.env) != null;
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final resolver = CLITokenResolver();
    final resolution = resolver.resolve(UsageProvider.groq, env: context.env);
    if (resolution == null) {
      throw Exception('No Groq API key found');
    }

    final apiKey = resolution.token;
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    // Groq exposes rate-limit info via response headers on a lightweight request
    final response = await http.get(
      Uri.parse('https://api.groq.com/openai/v1/models'),
      headers: headers,
    );

    if (response.statusCode == 401) {
      throw Exception('Invalid Groq API key');
    }

    if (response.statusCode != 200) {
      throw Exception('Groq API error: ${response.statusCode}');
    }

    final snapshot = _parseRateLimitHeaders(response.headers);

    return ProviderFetchResult(
      usage: snapshot,
      sourceLabel: 'api',
      strategyID: id,
      strategyKind: kind,
    );
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => false;

  UsageSnapshot _parseRateLimitHeaders(Map<String, String> headers) {
    RateWindow? primary;

    final limitRequests = headers['x-ratelimit-limit-requests'];
    final remainingRequests = headers['x-ratelimit-remaining-requests'];
    final resetRequests = headers['x-ratelimit-reset-requests'];

    if (limitRequests != null && remainingRequests != null) {
      final limit = double.tryParse(limitRequests) ?? 1;
      final remaining = double.tryParse(remainingRequests) ?? 0;
      final usedPercent = limit > 0 ? ((limit - remaining) / limit) * 100 : 0.0;

      primary = RateWindow(
        usedPercent: usedPercent.clamp(0.0, 100.0),
        windowMinutes: null,
        resetsAt: resetRequests != null
            ? DateTime.tryParse(resetRequests)
            : null,
      );
    }

    return UsageSnapshot(
      primary: primary,
      updatedAt: DateTime.now(),
      identity: const ProviderIdentitySnapshot(
        providerID: UsageProvider.groq,
        loginMethod: 'api-key',
      ),
    );
  }
}
