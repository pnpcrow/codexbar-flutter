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

/// Devin web fetch strategy.
/// Uses browser cookies to fetch from app.devin.ai API.
class DevinWebFetchStrategy extends FetchStrategy {
  @override
  String get id => 'devin.web';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.web;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    final resolver = BrowserCookieResolver();
    return await resolver.hasPlausibleSession(UsageProvider.devin);
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final resolver = BrowserCookieResolver();
    final cookies = await resolver.resolve(UsageProvider.devin);
    if (cookies == null) {
      throw Exception('No Devin cookies found');
    }

    final headers = {'Cookie': cookies.cookieHeader};

    // Try multiple URL patterns for quota usage
    final urls = [
      'https://app.devin.ai/api/billing/quota/usage',
      'https://app.devin.ai/api/org/billing/quota/usage',
      'https://app.devin.ai/api/organizations/billing/quota/usage',
    ];

    Map<String, dynamic>? usageJson;
    for (final url in urls) {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        usageJson = jsonDecode(response.body) as Map<String, dynamic>;
        break;
      }
    }

    if (usageJson == null) {
      throw Exception('Failed to fetch Devin usage from any endpoint');
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
    RateWindow? secondary;

    // Parse daily percentage (may be 0-1 or 0-100 scale)
    final dailyRaw = (json['daily_percentage'] as num?)?.toDouble();
    if (dailyRaw != null) {
      final dailyPercent = dailyRaw > 1 ? dailyRaw : dailyRaw * 100;
      primary = RateWindow(
        usedPercent: dailyPercent.clamp(0, 100),
        windowMinutes: 1440, // 24 hours
        resetsAt: json['daily_reset_at'] != null
            ? DateTime.tryParse(json['daily_reset_at'] as String)
            : null,
      );
    }

    // Parse weekly percentage
    final weeklyRaw = (json['weekly_percentage'] as num?)?.toDouble();
    if (weeklyRaw != null) {
      final weeklyPercent = weeklyRaw > 1 ? weeklyRaw : weeklyRaw * 100;
      secondary = RateWindow(
        usedPercent: weeklyPercent.clamp(0, 100),
        windowMinutes: 10080, // 7 days
        resetsAt: json['weekly_reset_at'] != null
            ? DateTime.tryParse(json['weekly_reset_at'] as String)
            : null,
      );
    }

    return UsageSnapshot(
      primary: primary,
      secondary: secondary,
      updatedAt: DateTime.now(),
      identity: const ProviderIdentitySnapshot(
        providerID: UsageProvider.devin,
        loginMethod: 'cookie',
      ),
    );
  }
}
