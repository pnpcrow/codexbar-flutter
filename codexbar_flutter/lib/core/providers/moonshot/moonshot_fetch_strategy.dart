import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../auth/cli_token_resolver.dart';
import '../../models/fetch_kind.dart';
import '../../models/fetch_result.dart';
import '../../models/provider_identity.dart';
import '../../models/usage_provider.dart';
import '../../models/usage_snapshot.dart';
import '../fetch_strategy.dart';

class MoonshotAPIFetchStrategy extends FetchStrategy {
  @override
  String get id => 'moonshot.api';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.apiToken;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    final resolver = CLITokenResolver();
    return resolver.resolve(UsageProvider.moonshot, env: context.env) != null;
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final resolver = CLITokenResolver();
    final resolution = resolver.resolve(UsageProvider.moonshot, env: context.env);
    if (resolution == null) {
      throw Exception('No Moonshot API key found');
    }

    final apiKey = resolution.token;
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Accept': 'application/json',
    };

    // Default to international region
    final response = await http.get(
      Uri.parse('https://api.moonshot.ai/v1/users/me/balance'),
      headers: headers,
    );

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Invalid Moonshot API key');
    }

    if (response.statusCode != 200) {
      throw Exception('Moonshot API error: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final snapshot = _parseBalanceResponse(json);

    return ProviderFetchResult(
      usage: snapshot,
      sourceLabel: 'api',
      strategyID: id,
      strategyKind: kind,
    );
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => false;

  UsageSnapshot _parseBalanceResponse(Map<String, dynamic> json) {
    final code = json['code'] as int? ?? -1;
    final status = json['status'] as bool? ?? false;

    if (code != 0 || !status) {
      throw Exception('Moonshot API error: code $code');
    }

    final data = json['data'] as Map<String, dynamic>? ?? {};
    final availableBalance = (data['available_balance'] as num?)?.toDouble() ?? 0;
    final cashBalance = (data['cash_balance'] as num?)?.toDouble() ?? 0;

    String loginMethod;
    if (cashBalance < 0) {
      loginMethod =
          'Balance: \$${availableBalance.toStringAsFixed(2)} \u00B7 \$${cashBalance.abs().toStringAsFixed(2)} in deficit';
    } else {
      loginMethod = 'Balance: \$${availableBalance.toStringAsFixed(2)}';
    }

    return UsageSnapshot(
      updatedAt: DateTime.now(),
      identity: ProviderIdentitySnapshot(
        providerID: UsageProvider.moonshot,
        loginMethod: loginMethod,
      ),
    );
  }
}
