import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../auth/browser_cookie_resolver.dart';
import '../../models/fetch_kind.dart';
import '../../models/fetch_result.dart';
import '../../models/provider_identity.dart';
import '../../models/rate_window.dart';
import '../../models/usage_provider.dart';
import '../../models/usage_snapshot.dart';
import '../fetch_strategy.dart';

/// Qoder web fetch strategy.
/// Uses browser cookies to fetch from qoder.com API.
class QoderWebFetchStrategy extends FetchStrategy {
  @override
  String get id => 'qoder.web';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.web;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    final resolver = BrowserCookieResolver();
    return await resolver.hasPlausibleSession(UsageProvider.qoder);
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final resolver = BrowserCookieResolver();
    final cookies = await resolver.resolve(UsageProvider.qoder);
    if (cookies == null) {
      throw Exception('No Qoder cookies found');
    }

    final headers = {'Cookie': cookies.cookieHeader};

    // Try international endpoint first, then China
    final urls = [
      'https://qoder.com/api/v2/me/usages/big_model_credits',
      'https://qoder.com.cn/api/v2/me/usages/big_model_credits',
    ];

    Map<String, dynamic>? usageJson;
    for (final url in urls) {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        usageJson = jsonDecode(response.body) as Map<String, dynamic>;
        break;
      }
      if (response.statusCode == 401) {
        throw Exception('Unauthorized - sign in to qoder.com');
      }
    }

    if (usageJson == null) {
      throw Exception('Failed to fetch Qoder usage from any endpoint');
    }

    final snapshot = _parseUsageResponse(usageJson);

    return ProviderFetchResult(
      usage: snapshot,
      sourceLabel: 'web',
      strategyID: id,
      strategyKind: kind,
    );
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => true;

  UsageSnapshot _parseUsageResponse(Map<String, dynamic> json) {
    RateWindow? primary;

    final summary = json['totalQuota'] as Map<String, dynamic>?;
    final quotaSummary = summary?['quotaSummary'] as Map<String, dynamic>?;

    if (quotaSummary != null) {
      final usagePercentage =
          (quotaSummary['usagePercentage'] as num?)?.toDouble();

      if (usagePercentage != null) {
        primary = RateWindow(
          usedPercent: usagePercentage.clamp(0, 100),
          windowMinutes: null,
          resetsAt: _parseResetAt(quotaSummary['nextResetAt']),
        );
      } else {
        final usedValue = (quotaSummary['usedValue'] as num?)?.toDouble();
        final limitValue = (quotaSummary['limitValue'] as num?)?.toDouble();
        if (usedValue != null && limitValue != null && limitValue > 0) {
          primary = RateWindow(
            usedPercent: ((usedValue / limitValue) * 100).clamp(0, 100),
            windowMinutes: null,
            resetsAt: _parseResetAt(quotaSummary['nextResetAt']),
          );
        }
      }
    }

    return UsageSnapshot(
      primary: primary,
      updatedAt: DateTime.now(),
      identity: const ProviderIdentitySnapshot(
        providerID: UsageProvider.qoder,
        loginMethod: 'cookie',
      ),
    );
  }

  DateTime? _parseResetAt(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    if (value is num) {
      // Unix timestamp
      return DateTime.fromMillisecondsSinceEpoch((value * 1000).toInt());
    }
    return null;
  }
}
