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

/// ElevenLabs API fetch strategy.
/// Uses ELEVENLABS_API_KEY to fetch subscription/usage data.
class ElevenLabsAPIFetchStrategy extends FetchStrategy {
  @override
  String get id => 'elevenlabs.api';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.apiToken;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    final resolver = CLITokenResolver();
    return resolver.resolve(UsageProvider.elevenlabs, env: context.env) != null;
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final resolver = CLITokenResolver();
    final resolution = resolver.resolve(UsageProvider.elevenlabs, env: context.env);
    if (resolution == null) {
      throw Exception('No ElevenLabs API key found');
    }

    final apiKey = resolution.token;
    final headers = {
      'xi-api-key': apiKey,
      'Content-Type': 'application/json',
    };

    final response = await http.get(
      Uri.parse('https://api.elevenlabs.io/v1/user/subscription'),
      headers: headers,
    );

    if (response.statusCode == 401) {
      throw Exception('Invalid ElevenLabs API key');
    }

    if (response.statusCode != 200) {
      throw Exception('ElevenLabs API error: ${response.statusCode}');
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

    final characterCount = (json['character_count'] as num?)?.toDouble() ?? 0;
    final characterLimit = (json['character_limit'] as num?)?.toDouble() ?? 1;
    final percentUsed = characterLimit > 0
        ? (characterCount / characterLimit) * 100
        : 0.0;

    primary = RateWindow(
      usedPercent: percentUsed.clamp(0.0, 100.0),
      windowMinutes: null,
      resetsAt: json['next_character_count_reset_unix'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['next_character_count_reset_unix'] as int) * 1000,
            )
          : null,
    );

    return UsageSnapshot(
      primary: primary,
      updatedAt: DateTime.now(),
      identity: const ProviderIdentitySnapshot(
        providerID: UsageProvider.elevenlabs,
        loginMethod: 'api-key',
      ),
    );
  }
}
