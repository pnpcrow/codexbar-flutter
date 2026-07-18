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

/// Deepgram API fetch strategy.
/// Uses DEEPGRAM_API_KEY to fetch usage from Deepgram API.
class DeepgramAPIFetchStrategy extends FetchStrategy {
  @override
  String get id => 'deepgram.api';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.apiToken;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    final resolver = CLITokenResolver();
    return resolver.resolve(UsageProvider.deepgram, env: context.env) != null;
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final resolver = CLITokenResolver();
    final resolution =
        resolver.resolve(UsageProvider.deepgram, env: context.env);
    if (resolution == null) {
      throw Exception('No Deepgram API key found');
    }

    final apiKey = resolution.token;
    final headers = {
      'Authorization': 'Token $apiKey',
      'Content-Type': 'application/json',
    };

    final response = await http.get(
      Uri.parse('https://api.deepgram.com/v1/projects'),
      headers: headers,
    );

    if (response.statusCode == 401) {
      throw Exception('Invalid Deepgram API key');
    }

    if (response.statusCode != 200) {
      throw Exception('Deepgram API error: ${response.statusCode}');
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

    final projects = json['projects'] as List<dynamic>?;
    if (projects != null && projects.isNotEmpty) {
      final project = projects[0] as Map<String, dynamic>;
      final totalHours = (project['total_hours'] as num?)?.toDouble() ?? 0;
      final maxHours = (project['max_hours'] as num?)?.toDouble() ?? 0;
      final percentUsed =
          maxHours > 0 ? (totalHours / maxHours) * 100 : 0.0;

      primary = RateWindow(
        usedPercent: percentUsed.clamp(0.0, 100.0),
        windowMinutes: null,
        resetsAt: project['resets_at'] != null
            ? DateTime.parse(project['resets_at'] as String)
            : null,
      );
    }

    return UsageSnapshot(
      primary: primary,
      updatedAt: DateTime.now(),
      identity: const ProviderIdentitySnapshot(
        providerID: UsageProvider.deepgram,
        loginMethod: 'api-key',
      ),
    );
  }
}
