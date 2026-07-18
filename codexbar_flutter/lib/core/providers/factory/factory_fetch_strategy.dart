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

/// Factory web fetch strategy.
/// Uses browser cookies to fetch from factory.ai API.
class FactoryWebFetchStrategy extends FetchStrategy {
  @override
  String get id => 'factory.web';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.web;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    final resolver = BrowserCookieResolver();
    return await resolver.hasPlausibleSession(UsageProvider.factory);
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final resolver = BrowserCookieResolver();
    final cookies = await resolver.resolve(UsageProvider.factory);
    if (cookies == null) {
      throw Exception('No Factory cookies found');
    }

    final headers = {'Cookie': cookies.cookieHeader};

    // Fetch user identity
    final meResponse = await http.get(
      Uri.parse('https://app.factory.ai/api/app/auth/me'),
      headers: headers,
    );
    if (meResponse.statusCode == 401) {
      throw Exception('Unauthorized - sign in to factory.ai');
    }

    String? userId;
    String? accountEmail;
    if (meResponse.statusCode == 200) {
      final meJson = jsonDecode(meResponse.body) as Map<String, dynamic>;
      userId = meJson['id'] as String?;
      accountEmail = meJson['email'] as String?;
    }

    // Fetch subscription usage
    final usageUrl = userId != null
        ? 'https://app.factory.ai/api/organization/subscription/usage?useCache=true&userId=$userId'
        : 'https://app.factory.ai/api/organization/subscription/usage?useCache=true';

    final usageResponse = await http.get(
      Uri.parse(usageUrl),
      headers: headers,
    );

    if (usageResponse.statusCode != 200) {
      throw Exception('Failed to fetch Factory usage: ${usageResponse.statusCode}');
    }

    final json = jsonDecode(usageResponse.body) as Map<String, dynamic>;
    final snapshot = _parseUsageResponse(json, accountEmail);

    return ProviderFetchResult(
      usage: snapshot,
      sourceLabel: 'web',
      strategyID: id,
      strategyKind: kind,
    );
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => true;

  UsageSnapshot _parseUsageResponse(
    Map<String, dynamic> json,
    String? accountEmail,
  ) {
    RateWindow? primary;

    final usedRatio = (json['usedRatio'] as num?)?.toDouble();
    if (usedRatio != null) {
      primary = RateWindow(
        usedPercent: (usedRatio * 100).clamp(0, 100),
        windowMinutes: null,
      );
    } else {
      final used = (json['standardUserTokens'] as num?)?.toDouble();
      final allowance = (json['standardAllowance'] as num?)?.toDouble();
      if (used != null && allowance != null && allowance > 0) {
        primary = RateWindow(
          usedPercent: ((used / allowance) * 100).clamp(0, 100),
          windowMinutes: null,
        );
      }
    }

    return UsageSnapshot(
      primary: primary,
      updatedAt: DateTime.now(),
      identity: ProviderIdentitySnapshot(
        providerID: UsageProvider.factory,
        accountEmail: accountEmail,
        loginMethod: 'cookie',
      ),
    );
  }
}
