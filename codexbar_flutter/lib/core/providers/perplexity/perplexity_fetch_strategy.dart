import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../auth/cli_token_resolver.dart';
import '../../models/fetch_kind.dart';
import '../../models/fetch_result.dart';
import '../../models/provider_identity.dart';
import '../../models/rate_window.dart';
import '../../models/usage_provider.dart';
import '../../models/usage_snapshot.dart';
import '../fetch_strategy.dart';

/// Perplexity API fetch strategy.
/// Uses PERPLEXITY_SESSION_TOKEN to fetch usage from Perplexity API.
class PerplexityAPIFetchStrategy extends FetchStrategy {
  @override
  String get id => 'perplexity.api';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.apiToken;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    final resolver = CLITokenResolver();
    return resolver.resolve(UsageProvider.perplexity, env: context.env) != null;
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final resolver = CLITokenResolver();
    final resolution =
        resolver.resolve(UsageProvider.perplexity, env: context.env);
    if (resolution == null) {
      throw Exception('No Perplexity session token found');
    }

    final apiKey = resolution.token;
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    final response = await http.get(
      Uri.parse('https://api.perplexity.ai/user/usage'),
      headers: headers,
    );

    if (response.statusCode == 401) {
      throw Exception('Invalid Perplexity session token');
    }

    if (response.statusCode != 200) {
      throw Exception('Perplexity API error: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final snapshot = _parseUsageResponse(json);

    return ProviderFetchResult(
      usage: snapshot,
      sourceLabel: 'api',
      strategyID: id,
      strategyKind: kind,
    );
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => false;

  UsageSnapshot _parseUsageResponse(Map<String, dynamic> json) {
    RateWindow? primary;

    final totalQueries = (json['total_queries'] as num?)?.toDouble() ?? 0;
    final maxQueries = (json['max_queries'] as num?)?.toDouble() ?? 0;
    final percentUsed =
        maxQueries > 0 ? (totalQueries / maxQueries) * 100 : 0.0;

    primary = RateWindow(
      usedPercent: percentUsed.clamp(0.0, 100.0),
      windowMinutes: json['window_minutes'] as int?,
      resetsAt: json['resets_at'] != null
          ? DateTime.parse(json['resets_at'] as String)
          : null,
    );

    return UsageSnapshot(
      primary: primary,
      updatedAt: DateTime.now(),
      identity: const ProviderIdentitySnapshot(
        providerID: UsageProvider.perplexity,
        loginMethod: 'session-token',
      ),
    );
  }
}
