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

class AmpAPIFetchStrategy extends FetchStrategy {
  @override
  String get id => 'amp.api';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.apiToken;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    final resolver = CLITokenResolver();
    return resolver.resolve(UsageProvider.amp, env: context.env) != null;
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final resolver = CLITokenResolver();
    final resolution = resolver.resolve(UsageProvider.amp, env: context.env);
    if (resolution == null) {
      throw Exception('No Amp API token found');
    }

    final apiKey = resolution.token;
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'accept': 'application/json',
      'content-type': 'application/json',
    };

    final response = await http.post(
      Uri.parse('https://ampcode.com/api/internal?userDisplayBalanceInfo'),
      headers: headers,
      body: jsonEncode({
        'method': 'userDisplayBalanceInfo',
        'params': {},
      }),
    );

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Invalid Amp API token');
    }

    if (response.statusCode != 200) {
      throw Exception('Amp API error: ${response.statusCode}');
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
    final ok = json['ok'] as bool? ?? false;
    if (!ok) {
      final errorCode = json['error']?['code'] as String?;
      if (errorCode == 'auth-required') {
        throw Exception('Invalid Amp API token');
      }
      throw Exception('Amp API error: ${json['error']?['message'] ?? 'Unknown'}');
    }

    final result = json['result'] as Map<String, dynamic>?;
    final displayText = result?['displayText'] as String?;

    if (displayText == null || displayText.isEmpty) {
      return UsageSnapshot(
        updatedAt: DateTime.now(),
        identity: const ProviderIdentitySnapshot(
          providerID: UsageProvider.amp,
          loginMethod: 'api-token',
        ),
      );
    }

    // Parse the display text for free quota and balance info
    final lower = displayText.toLowerCase();
    double? usedPercent;
    String? description;

    if (lower.contains('free')) {
      description = 'Amp Free available';
      usedPercent = 0;
    }

    return UsageSnapshot(
      primary: usedPercent != null
          ? RateWindow(
              usedPercent: usedPercent,
              resetDescription: description,
            )
          : null,
      updatedAt: DateTime.now(),
      identity: const ProviderIdentitySnapshot(
        providerID: UsageProvider.amp,
        loginMethod: 'api-token',
      ),
    );
  }
}
