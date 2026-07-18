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

/// OpenAI API fetch strategy.
/// Uses OPENAI_API_KEY to fetch usage from OpenAI API.
class OpenAIAPIFetchStrategy extends FetchStrategy {
  @override
  String get id => 'openai.api';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.apiToken;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    final resolver = CLITokenResolver();
    return resolver.resolve(UsageProvider.openai, env: context.env) != null;
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final resolver = CLITokenResolver();
    final resolution = resolver.resolve(UsageProvider.openai, env: context.env);
    if (resolution == null) {
      throw Exception('No OpenAI API key found');
    }

    final apiKey = resolution.token;
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    // Fetch usage from OpenAI API
    // Note: OpenAI doesn't have a simple usage percentage API,
    // so we fetch billing/usage data
    final response = await http.get(
      Uri.parse('https://api.openai.com/v1/organization/usage'),
      headers: headers,
    );

    if (response.statusCode == 401) {
      throw Exception('Invalid OpenAI API key');
    }

    if (response.statusCode != 200) {
      throw Exception('OpenAI API error: ${response.statusCode}');
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

    // Parse usage data
    if (json['data'] != null) {
      final data = json['data'] as List<dynamic>;
      if (data.isNotEmpty) {
        final usage = data[0] as Map<String, dynamic>;
        final totalUsage = (usage['total_usage'] as num?)?.toDouble() ?? 0;
        final hardLimit = (usage['hard_limit'] as num?)?.toDouble() ?? 100;
        final percentUsed = hardLimit > 0 ? (totalUsage / hardLimit) * 100 : 0.0;

        primary = RateWindow(
          usedPercent: percentUsed.clamp(0.0, 100.0),
          windowMinutes: null,
          resetsAt: usage['resets_at'] != null
              ? DateTime.parse(usage['resets_at'] as String)
              : null,
        );
      }
    }

    return UsageSnapshot(
      primary: primary,
      updatedAt: DateTime.now(),
      identity: const ProviderIdentitySnapshot(
        providerID: UsageProvider.openai,
        loginMethod: 'api-key',
      ),
    );
  }
}
