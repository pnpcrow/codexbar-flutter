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

class DeepSeekAPIFetchStrategy extends FetchStrategy {
  @override
  String get id => 'deepseek.api';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.apiToken;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    final resolver = CLITokenResolver();
    return resolver.resolve(UsageProvider.deepseek, env: context.env) != null;
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final resolver = CLITokenResolver();
    final resolution = resolver.resolve(UsageProvider.deepseek, env: context.env);
    if (resolution == null) {
      throw Exception('No DeepSeek API key found');
    }

    final apiKey = resolution.token;
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Accept': 'application/json',
    };

    final response = await http.get(
      Uri.parse('https://api.deepseek.com/user/balance'),
      headers: headers,
    );

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Invalid DeepSeek API key');
    }

    if (response.statusCode != 200) {
      throw Exception('DeepSeek API error: ${response.statusCode}');
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
    final isAvailable = json['is_available'] as bool? ?? false;
    final balanceInfos = json['balance_infos'] as List<dynamic>? ?? [];

    if (balanceInfos.isEmpty) {
      return UsageSnapshot(
        primary: const RateWindow(
          usedPercent: 100,
          resetDescription: 'No balance data',
        ),
        updatedAt: DateTime.now(),
        identity: const ProviderIdentitySnapshot(
          providerID: UsageProvider.deepseek,
          loginMethod: 'api-key',
        ),
      );
    }

    // Prefer USD, then first with positive balance
    Map<String, dynamic>? selected;
    for (final info in balanceInfos) {
      final entry = info as Map<String, dynamic>;
      if (entry['currency'] == 'USD') {
        final total = double.tryParse(entry['total_balance'] as String? ?? '0') ?? 0;
        if (total > 0) {
          selected = entry;
          break;
        }
      }
    }
    selected ??= balanceInfos.first as Map<String, dynamic>;

    final currency = selected['currency'] as String? ?? 'USD';
    final symbol = currency == 'CNY' ? '\u00A5' : '\$';
    final totalBalance = double.tryParse(selected['total_balance'] as String? ?? '0') ?? 0;
    final grantedBalance = double.tryParse(selected['granted_balance'] as String? ?? '0') ?? 0;
    final toppedUpBalance = double.tryParse(selected['topped_up_balance'] as String? ?? '0') ?? 0;

    String balanceDetail;
    double usedPercent;
    if (totalBalance <= 0) {
      balanceDetail = '${symbol}0.00 \u2014 add credits at platform.deepseek.com';
      usedPercent = 100;
    } else if (!isAvailable) {
      balanceDetail = 'Balance unavailable for API calls';
      usedPercent = 100;
    } else {
      final total = '$symbol${totalBalance.toStringAsFixed(2)}';
      final paid = '$symbol${toppedUpBalance.toStringAsFixed(2)}';
      final granted = '$symbol${grantedBalance.toStringAsFixed(2)}';
      balanceDetail = '$total (Paid: $paid / Granted: $granted)';
      usedPercent = 0;
    }

    return UsageSnapshot(
      primary: RateWindow(
        usedPercent: usedPercent,
        resetDescription: balanceDetail,
      ),
      updatedAt: DateTime.now(),
      identity: const ProviderIdentitySnapshot(
        providerID: UsageProvider.deepseek,
        loginMethod: 'api-key',
      ),
    );
  }
}
