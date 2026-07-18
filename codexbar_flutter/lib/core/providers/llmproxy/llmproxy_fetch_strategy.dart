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

/// LLM Proxy API fetch strategy.
/// Uses LLMPROXY_API_KEY to fetch usage data.
class LLMProxyAPIFetchStrategy extends FetchStrategy {
  @override
  String get id => 'llmproxy.api';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.apiToken;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    final resolver = CLITokenResolver();
    return resolver.resolve(UsageProvider.llmproxy, env: context.env) != null;
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final resolver = CLITokenResolver();
    final resolution = resolver.resolve(UsageProvider.llmproxy, env: context.env);
    if (resolution == null) {
      throw Exception('No LLM Proxy API key found');
    }

    final apiKey = resolution.token;
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    final response = await http.get(
      Uri.parse('https://api.llmproxy.com/v1/usage'),
      headers: headers,
    );

    if (response.statusCode == 401) {
      throw Exception('Invalid LLM Proxy API key');
    }

    if (response.statusCode != 200) {
      throw Exception('LLM Proxy API error: ${response.statusCode}');
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

    final used = (json['used'] as num?)?.toDouble() ?? 0;
    final limit = (json['limit'] as num?)?.toDouble() ?? 100;
    final percentUsed = limit > 0 ? (used / limit) * 100 : 0.0;

    primary = RateWindow(
      usedPercent: percentUsed.clamp(0.0, 100.0),
      windowMinutes: json['window_minutes'] as int?,
      resetsAt: json['resets_at'] != null
          ? DateTime.tryParse(json['resets_at'] as String)
          : null,
    );

    return UsageSnapshot(
      primary: primary,
      updatedAt: DateTime.now(),
      identity: const ProviderIdentitySnapshot(
        providerID: UsageProvider.llmproxy,
        loginMethod: 'api-key',
      ),
    );
  }
}
