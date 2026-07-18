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

/// Kimi API fetch strategy.
/// Uses KIMI_AUTH_TOKEN or KIMI_API_KEY to fetch usage from Kimi API.
class KimiAPIFetchStrategy extends FetchStrategy {
  @override
  String get id => 'kimi.api';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.apiToken;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    final resolver = CLITokenResolver();
    return resolver.resolve(UsageProvider.kimi, env: context.env) != null;
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final resolver = CLITokenResolver();
    final resolution = resolver.resolve(UsageProvider.kimi, env: context.env);
    if (resolution == null) {
      throw Exception('No Kimi API key found');
    }

    final apiKey = resolution.token;
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    final response = await http.get(
      Uri.parse('https://api.moonshot.cn/v1/users/me'),
      headers: headers,
    );

    if (response.statusCode == 401) {
      throw Exception('Invalid Kimi API key');
    }

    if (response.statusCode != 200) {
      throw Exception('Kimi API error: ${response.statusCode}');
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

    final data = json['data'] as Map<String, dynamic>?;
    if (data != null) {
      final totalTokens = (data['total_tokens'] as num?)?.toDouble() ?? 0;
      final limitTokens = (data['limit_tokens'] as num?)?.toDouble() ?? 0;
      final percentUsed =
          limitTokens > 0 ? (totalTokens / limitTokens) * 100 : 0.0;

      primary = RateWindow(
        usedPercent: percentUsed.clamp(0.0, 100.0),
        windowMinutes: null,
        resetsAt: data['resets_at'] != null
            ? DateTime.parse(data['resets_at'] as String)
            : null,
      );
    }

    return UsageSnapshot(
      primary: primary,
      updatedAt: DateTime.now(),
      identity: const ProviderIdentitySnapshot(
        providerID: UsageProvider.kimi,
        loginMethod: 'api-key',
      ),
    );
  }
}
