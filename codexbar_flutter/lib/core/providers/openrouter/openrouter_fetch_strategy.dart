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

class OpenRouterAPIFetchStrategy extends FetchStrategy {
  @override
  String get id => 'openrouter.api';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.apiToken;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    final resolver = CLITokenResolver();
    return resolver.resolve(UsageProvider.openrouter, env: context.env) != null;
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final resolver = CLITokenResolver();
    final resolution = resolver.resolve(UsageProvider.openrouter, env: context.env);
    if (resolution == null) {
      throw Exception('No OpenRouter API token found');
    }

    final apiKey = resolution.token;
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Accept': 'application/json',
      'HTTP-Referer': 'https://github.com/nicobailon/codexbar',
      'X-Title': 'CodexBar',
    };

    final response = await http.get(
      Uri.parse('https://openrouter.ai/api/v1/credits'),
      headers: headers,
    );

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Invalid OpenRouter API token');
    }

    if (response.statusCode != 200) {
      throw Exception('OpenRouter API error: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final snapshot = _parseCreditsResponse(json);

    return ProviderFetchResult(
      usage: snapshot,
      sourceLabel: 'api',
      strategyID: id,
      strategyKind: kind,
    );
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => false;

  UsageSnapshot _parseCreditsResponse(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final totalCredits = (data['total_credits'] as num?)?.toDouble() ?? 0;
    final totalUsage = (data['total_usage'] as num?)?.toDouble() ?? 0;
    final balance = (totalCredits - totalUsage).clamp(0, double.infinity);
    final usedPercent = totalCredits > 0
        ? ((totalUsage / totalCredits) * 100).clamp(0.0, 100.0).toDouble()
        : 0.0;

    final balanceStr = '\$${balance.toStringAsFixed(2)}';

    return UsageSnapshot(
      primary: RateWindow(
        usedPercent: usedPercent,
      ),
      updatedAt: DateTime.now(),
      identity: ProviderIdentitySnapshot(
        providerID: UsageProvider.openrouter,
        loginMethod: 'Balance: $balanceStr',
      ),
    );
  }
}
