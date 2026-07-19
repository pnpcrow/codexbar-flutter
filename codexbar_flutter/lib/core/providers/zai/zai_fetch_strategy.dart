import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../debug/debug_logger.dart';
import '../../models/fetch_kind.dart';
import '../../models/fetch_result.dart';
import '../../models/provider_identity.dart';
import '../../models/rate_window.dart';
import '../../models/usage_provider.dart';
import '../../models/usage_snapshot.dart';
import '../fetch_strategy.dart';

/// Zai API fetch strategy - uses Z_AI_API_KEY from env or settings.
class ZaiAPIFetchStrategy extends FetchStrategy {
  @override
  String get id => 'zai.api';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.apiToken;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    return _getApiKey(context) != null;
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final apiKey = _getApiKey(context);
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Z_AI_API_KEY not set. Get your API key from https://z.ai/manage-apikey');
    }

    // Try different API regions
    for (final host in ['api.z.ai', 'open.bigmodel.cn']) {
      final url = 'https://$host/api/monitor/usage/quota/limit';
      DebugLogger.request('Zai', 'GET', url);

      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Accept': 'application/json',
          },
        );
        DebugLogger.response('Zai', url, response.statusCode, response.body);

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          return _parseResponse(json, host);
        } else if (response.statusCode == 401 || response.statusCode == 403) {
          throw Exception('Invalid Zai API key. Get one from https://z.ai/manage-apikey');
        }
      } catch (e) {
        if (e is Exception && e.toString().contains('Invalid Zai')) rethrow;
        continue;
      }
    }

    throw Exception('Zai API failed. Check your API key.');
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => false;

  String? _getApiKey(ProviderFetchContext context) {
    final env = context.env.isEmpty ? Platform.environment : context.env;
    return env['Z_AI_API_KEY']?.trim();
  }

  ProviderFetchResult _parseResponse(Map<String, dynamic> json, String host) {
    final success = json['success'] as bool? ?? false;
    final code = json['code'] as int? ?? 0;

    if (!success || code != 200) {
      final msg = json['msg'] as String? ?? 'Unknown error';
      throw Exception('Zai API error: $msg');
    }

    final data = json['data'] as Map<String, dynamic>? ?? {};
    final limits = data['limits'] as List<dynamic>? ?? [];
    final planName = _extractPlanName(data);

    RateWindow? tokenLimit;
    RateWindow? timeLimit;

    for (final limit in limits) {
      final entry = limit as Map<String, dynamic>;
      final type = entry['type'] as String? ?? '';
      final unit = entry['unit'] as int? ?? 0;
      final number = entry['number'] as int? ?? 0;
      final percentage = (entry['percentage'] as num?)?.toDouble() ?? 0;
      final nextResetTime = entry['nextResetTime'] as int?;

      final windowMinutes = _computeWindowMinutes(unit, number);
      final resetsAt = nextResetTime != null
          ? DateTime.fromMillisecondsSinceEpoch(nextResetTime)
          : null;

      final window = RateWindow(
        usedPercent: percentage,
        windowMinutes: windowMinutes,
        resetsAt: resetsAt,
      );

      if (type == 'TOKENS_LIMIT') {
        tokenLimit = window;
      } else if (type == 'TIME_LIMIT') {
        timeLimit = window;
      }
    }

    return ProviderFetchResult(
      usage: UsageSnapshot(
        primary: tokenLimit ?? timeLimit,
        secondary: (tokenLimit != null && timeLimit != null) ? timeLimit : null,
        updatedAt: DateTime.now(),
        identity: ProviderIdentitySnapshot(
          providerID: UsageProvider.zai,
          loginMethod: planName ?? 'api ($host)',
        ),
      ),
      sourceLabel: 'api',
      strategyID: id,
      strategyKind: kind,
    );
  }

  String? _extractPlanName(Map<String, dynamic> data) {
    for (final key in ['planName', 'plan', 'plan_type', 'packageName']) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  int? _computeWindowMinutes(int unit, int number) {
    if (number <= 0) return null;
    switch (unit) {
      case 5: return number; // minutes
      case 3: return number * 60; // hours
      case 1: return number * 24 * 60; // days
      case 6: return number * 7 * 24 * 60; // weeks
      default: return null;
    }
  }
}
