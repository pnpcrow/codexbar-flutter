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

class SyntheticAPIFetchStrategy extends FetchStrategy {
  @override
  String get id => 'synthetic.api';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.apiToken;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    final resolver = CLITokenResolver();
    return resolver.resolve(UsageProvider.synthetic, env: context.env) != null;
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final resolver = CLITokenResolver();
    final resolution = resolver.resolve(UsageProvider.synthetic, env: context.env);
    if (resolution == null) {
      throw Exception('No Synthetic API key found');
    }

    final apiKey = resolution.token;
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Accept': 'application/json',
    };

    final response = await http.get(
      Uri.parse('https://api.synthetic.new/v2/quotas'),
      headers: headers,
    );

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Invalid Synthetic API key');
    }

    if (response.statusCode != 200) {
      throw Exception('Synthetic API error: ${response.statusCode}');
    }

    final json = jsonDecode(response.body);
    final snapshot = _parseQuotaResponse(json);

    return ProviderFetchResult(
      usage: snapshot,
      sourceLabel: 'api',
      strategyID: id,
      strategyKind: kind,
    );
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => false;

  UsageSnapshot _parseQuotaResponse(dynamic json) {
    // Normalize root object
    Map<String, dynamic> root;
    if (json is Map<String, dynamic>) {
      root = json;
    } else if (json is List) {
      root = {'quotas': json};
    } else {
      throw Exception('Unexpected Synthetic response format');
    }

    final dataDict = root['data'] as Map<String, dynamic>?;
    final planName = _extractPlanName(root, dataDict);

    // Try slot-based parsing first: rollingFiveHourLimit, weeklyTokenLimit, search.hourly
    final rolling = _namedQuota(
      root['rollingFiveHourLimit'] ?? dataDict?['rollingFiveHourLimit'],
      'Rolling five-hour limit',
    );
    final weekly = _namedQuota(
      root['weeklyTokenLimit'] ?? dataDict?['weeklyTokenLimit'],
      'Weekly token limit',
    );
    final searchHourly = _namedQuota(
      (root['search'] as Map<String, dynamic>?)?['hourly'] ??
          (dataDict?['search'] as Map<String, dynamic>?)?['hourly'],
      'Search hourly',
    );

    final slots = [rolling, weekly, searchHourly];
    final hasSlots = slots.any((s) => s != null);

    RateWindow? primary;
    RateWindow? secondary;
    RateWindow? tertiary;

    if (hasSlots) {
      primary = slots[0] != null ? _parseQuota(slots[0]!) : null;
      secondary = slots[1] != null ? _parseQuota(slots[1]!) : null;
      tertiary = slots[2] != null ? _parseQuota(slots[2]!) : null;
    } else {
      // Fallback: find quota arrays in known keys
      final quotaArrays = [
        root['quotas'],
        root['quota'],
        root['limits'],
        root['usage'],
        root['entries'],
        dataDict?['quotas'],
        dataDict?['quota'],
        dataDict?['limits'],
        dataDict?['usage'],
      ];

      final quotas = <RateWindow>[];
      for (final arr in quotaArrays) {
        if (arr is List) {
          for (final item in arr) {
            if (item is Map<String, dynamic>) {
              final window = _parseQuota(item);
              if (window != null) {
                quotas.add(window);
              }
            }
          }
          if (quotas.isNotEmpty) break;
        }
      }

      primary = quotas.isNotEmpty ? quotas[0] : null;
      secondary = quotas.length > 1 ? quotas[1] : null;
      tertiary = quotas.length > 2 ? quotas[2] : null;
    }

    return UsageSnapshot(
      primary: primary,
      secondary: secondary,
      tertiary: tertiary,
      updatedAt: DateTime.now(),
      identity: ProviderIdentitySnapshot(
        providerID: UsageProvider.synthetic,
        loginMethod: planName,
      ),
    );
  }

  Map<String, dynamic>? _namedQuota(dynamic candidate, String label) {
    if (candidate is! Map<String, dynamic>) return null;
    final hasQuotaFields = _isQuotaPayload(candidate);
    if (!hasQuotaFields) return null;
    final payload = Map<String, dynamic>.from(candidate);
    if (payload['label'] == null && payload['name'] == null) {
      payload['label'] = label;
    }
    return payload;
  }

  bool _isQuotaPayload(Map<String, dynamic> payload) {
    return _firstDouble(payload, _limitKeys) != null ||
        _firstDouble(payload, _usedKeys) != null ||
        _firstDouble(payload, _remainingKeys) != null ||
        _normalizedPercent(_firstDouble(payload, _percentUsedKeys)) != null ||
        _normalizedPercent(_firstDouble(payload, _percentRemainingKeys)) != null;
  }

  RateWindow? _parseQuota(Map<String, dynamic> payload) {
    var usedPercent = _normalizedPercent(_firstDouble(payload, _percentUsedKeys));

    if (usedPercent == null) {
      final percentRemaining = _normalizedPercent(_firstDouble(payload, _percentRemainingKeys));
      if (percentRemaining != null) {
        usedPercent = 100 - percentRemaining;
      }
    }

    if (usedPercent == null) {
      var limit = _firstDouble(payload, _limitKeys);
      var used = _firstDouble(payload, _usedKeys);
      var remaining = _firstDouble(payload, _remainingKeys);

      if (limit == null && used != null && remaining != null) {
        limit = used + remaining;
      }
      if (used == null && limit != null && remaining != null) {
        used = limit - remaining;
      }
      if (remaining == null && limit != null && used != null) {
        remaining = (limit - used).clamp(0, double.infinity);
      }

      if (limit != null && used != null && limit > 0) {
        usedPercent = (used / limit) * 100;
      }
    }

    if (usedPercent == null) return null;
    final clamped = usedPercent.clamp(0.0, 100.0);

    final windowMinutes = _windowMinutes(payload);
    final resetsAt = _firstDate(payload, _resetKeys);
    final resetDescription =
        resetsAt == null ? _windowDescription(windowMinutes) : null;
    final nextRegenPercent =
        _normalizedPercent(_firstDouble(payload, _tickPercentKeys));

    return RateWindow(
      usedPercent: clamped,
      windowMinutes: windowMinutes,
      resetsAt: resetsAt,
      resetDescription: resetDescription,
      nextRegenPercent: nextRegenPercent,
    );
  }

  String? _extractPlanName(
    Map<String, dynamic> root,
    Map<String, dynamic>? dataDict,
  ) {
    for (final key in _planKeys) {
      final value = root[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    if (dataDict != null) {
      for (final key in _planKeys) {
        final value = dataDict[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
      }
    }
    return null;
  }

  double? _normalizedPercent(double? value) {
    if (value == null) return null;
    if (value <= 1) return value * 100;
    return value;
  }

  double? _firstDouble(Map<String, dynamic> payload, List<String> keys) {
    for (final key in keys) {
      final value = payload[key];
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value.trim());
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  DateTime? _firstDate(Map<String, dynamic> payload, List<String> keys) {
    for (final key in keys) {
      final value = payload[key];
      if (value is num) {
        final n = value.toDouble();
        if (n > 1000000000000) {
          return DateTime.fromMillisecondsSinceEpoch(n.toInt());
        }
        if (n > 1000000000) {
          return DateTime.fromMillisecondsSinceEpoch((n * 1000).toInt());
        }
      }
      if (value is String) {
        final n = double.tryParse(value.trim());
        if (n != null) {
          if (n > 1000000000000) {
            return DateTime.fromMillisecondsSinceEpoch(n.toInt());
          }
          if (n > 1000000000) {
            return DateTime.fromMillisecondsSinceEpoch((n * 1000).toInt());
          }
        }
        final date = DateTime.tryParse(value.trim());
        if (date != null) return date;
      }
    }
    return null;
  }

  int? _windowMinutes(Map<String, dynamic> payload) {
    // Try minutes first
    final minutes = _firstDouble(payload, _windowMinutesKeys);
    if (minutes != null) return minutes.toInt();

    // Try hours
    final hours = _firstDouble(payload, _windowHoursKeys);
    if (hours != null) return (hours * 60).round();

    // Try days
    final days = _firstDouble(payload, _windowDaysKeys);
    if (days != null) return (days * 24 * 60).round();

    // Try seconds
    final seconds = _firstDouble(payload, _windowSecondsKeys);
    if (seconds != null) return (seconds / 60).round();

    // Try string
    for (final key in _windowStringKeys) {
      final value = payload[key];
      if (value is String) {
        final parsed = _windowMinutesFromText(value);
        if (parsed != null) return parsed;
      }
    }

    return null;
  }

  int? _windowMinutesFromText(String text) {
    final normalized = text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '');
    if (normalized.isEmpty) return null;

    final suffixes = [
      ('minutes', 1.0),
      ('minute', 1.0),
      ('mins', 1.0),
      ('min', 1.0),
      ('m', 1.0),
      ('hours', 60.0),
      ('hour', 60.0),
      ('hrs', 60.0),
      ('hr', 60.0),
      ('h', 60.0),
      ('days', 1440.0),
      ('day', 1440.0),
      ('d', 1440.0),
    ];

    for (final (suffix, multiplier) in suffixes) {
      if (normalized.endsWith(suffix)) {
        final valueText = normalized.substring(0, normalized.length - suffix.length);
        final value = double.tryParse(valueText);
        if (value != null && value > 0) {
          return (value * multiplier).round();
        }
      }
    }
    return null;
  }

  String? _windowDescription(int? minutes) {
    if (minutes == null || minutes <= 0) return null;
    final dayMinutes = 24 * 60;
    if (minutes % dayMinutes == 0) {
      final days = minutes ~/ dayMinutes;
      return '$days day${days == 1 ? '' : 's'} window';
    }
    if (minutes % 60 == 0) {
      final hours = minutes ~/ 60;
      return '$hours hour${hours == 1 ? '' : 's'} window';
    }
    return '$minutes minute${minutes == 1 ? '' : 's'} window';
  }

  static const _planKeys = [
    'plan',
    'planName',
    'plan_name',
    'subscription',
    'subscriptionPlan',
    'tier',
    'package',
    'packageName',
  ];

  static const _percentUsedKeys = [
    'percentUsed',
    'usedPercent',
    'usagePercent',
    'usage_percent',
    'used_percent',
    'percent_used',
    'percent',
  ];

  static const _percentRemainingKeys = [
    'percentRemaining',
    'remainingPercent',
    'remaining_percent',
    'percent_remaining',
  ];

  static const _limitKeys = [
    'limit',
    'messageLimit',
    'message_limit',
    'messages',
    'maxRequests',
    'max_requests',
    'requestLimit',
    'request_limit',
    'quota',
    'max',
    'total',
    'capacity',
    'allowance',
  ];

  static const _usedKeys = [
    'used',
    'usage',
    'usedMessages',
    'used_messages',
    'messagesUsed',
    'messages_used',
    'requests',
    'requestCount',
    'request_count',
    'consumed',
    'spent',
  ];

  static const _remainingKeys = [
    'remaining',
    'left',
    'available',
    'balance',
  ];

  static const _resetKeys = [
    'resetAt',
    'reset_at',
    'resetsAt',
    'resets_at',
    'renewAt',
    'renew_at',
    'renewsAt',
    'renews_at',
    'nextTickAt',
    'next_tick_at',
    'nextRegenAt',
    'next_regen_at',
    'periodEnd',
    'period_end',
    'expiresAt',
    'expires_at',
    'endAt',
    'end_at',
  ];

  static const _tickPercentKeys = [
    'tickPercent',
    'tick_percent',
    'nextTickPercent',
    'next_tick_percent',
  ];

  static const _windowMinutesKeys = [
    'windowMinutes',
    'window_minutes',
    'periodMinutes',
    'period_minutes',
  ];

  static const _windowHoursKeys = [
    'windowHours',
    'window_hours',
    'periodHours',
    'period_hours',
  ];

  static const _windowDaysKeys = [
    'windowDays',
    'window_days',
    'periodDays',
    'period_days',
  ];

  static const _windowSecondsKeys = [
    'windowSeconds',
    'window_seconds',
    'periodSeconds',
    'period_seconds',
  ];

  static const _windowStringKeys = [
    'window',
    'windowLabel',
    'window_label',
    'period',
    'periodLabel',
    'period_label',
  ];
}
