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

class ZaiAPIFetchStrategy extends FetchStrategy {
  @override
  String get id => 'zai.api';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.apiToken;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    final resolver = CLITokenResolver();
    return resolver.resolve(UsageProvider.zai, env: context.env) != null;
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final resolver = CLITokenResolver();
    final resolution = resolver.resolve(UsageProvider.zai, env: context.env);
    if (resolution == null) {
      throw Exception('No Zai API token found');
    }

    final apiKey = resolution.token;
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'accept': 'application/json',
    };

    final response = await http.get(
      Uri.parse('https://api.z.ai/api/monitor/usage/quota/limit'),
      headers: headers,
    );

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Invalid Zai API token');
    }

    if (response.statusCode != 200) {
      throw Exception('Zai API error: ${response.statusCode}');
    }

    if (response.body.isEmpty) {
      throw Exception('Zai API returned empty response');
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
    RateWindow? sessionTokenLimit;
    RateWindow? timeLimit;

    for (final limit in limits) {
      final entry = limit as Map<String, dynamic>;
      final type = entry['type'] as String? ?? '';
      final unit = entry['unit'] as int? ?? 0;
      final number = entry['number'] as int? ?? 0;
      final usage = entry['usage'] as int?;
      final currentValue = entry['currentValue'] as int?;
      final remaining = entry['remaining'] as int?;
      final percentage = (entry['percentage'] as num?)?.toDouble() ?? 0;
      final nextResetTime = entry['nextResetTime'] as int?;

      final windowMinutes = _computeWindowMinutes(unit, number);
      final usedPercent = _computeUsedPercent(usage, currentValue, remaining, percentage);
      final resetsAt = nextResetTime != null
          ? DateTime.fromMillisecondsSinceEpoch(nextResetTime)
          : null;

      final window = RateWindow(
        usedPercent: usedPercent,
        windowMinutes: windowMinutes,
        resetsAt: resetsAt,
      );

      if (type == 'TOKENS_LIMIT') {
        if (tokenLimit == null ||
            (windowMinutes ?? 0) > (tokenLimit.windowMinutes ?? 0)) {
          if (tokenLimit != null) {
            sessionTokenLimit = tokenLimit;
          }
          tokenLimit = window;
        } else {
          sessionTokenLimit = window;
        }
      } else if (type == 'TIME_LIMIT') {
        timeLimit = window;
      }
    }

    final primary = tokenLimit ?? timeLimit;
    final secondary = (tokenLimit != null && timeLimit != null) ? timeLimit : null;

    return UsageSnapshot(
      primary: primary,
      secondary: secondary,
      tertiary: sessionTokenLimit,
      updatedAt: DateTime.now(),
      identity: ProviderIdentitySnapshot(
        providerID: UsageProvider.zai,
        loginMethod: planName,
      ),
    );
  }

  String? _extractPlanName(Map<String, dynamic> data) {
    final candidates = [
      data['planName'],
      data['plan'],
      data['plan_type'],
      data['packageName'],
    ];
    for (final candidate in candidates) {
      if (candidate is String) {
        final trimmed = candidate.trim();
        if (trimmed.isNotEmpty) return trimmed;
      }
    }
    return null;
  }

  int? _computeWindowMinutes(int unit, int number) {
    if (number <= 0) return null;
    switch (unit) {
      case 5: // minutes
        return number;
      case 3: // hours
        return number * 60;
      case 1: // days
        return number * 24 * 60;
      case 6: // weeks
        return number * 7 * 24 * 60;
      default:
        return null;
    }
  }

  double _computeUsedPercent(
    int? usage,
    int? currentValue,
    int? remaining,
    double percentage,
  ) {
    if (usage != null && usage > 0) {
      int? usedRaw;
      if (remaining != null) {
        final usedFromRemaining = usage - remaining;
        if (currentValue != null) {
          usedRaw = usedFromRemaining > currentValue ? usedFromRemaining : currentValue;
        } else {
          usedRaw = usedFromRemaining;
        }
      } else if (currentValue != null) {
        usedRaw = currentValue;
      }

      if (usedRaw != null) {
        final used = usedRaw.clamp(0, usage);
        final percent = (used / usage) * 100;
        return percent.clamp(0.0, 100.0);
      }
    }

    return percentage;
  }
}
