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

/// Cursor web fetch strategy.
/// Uses browser cookies to fetch from cursor.com API.
class CursorWebFetchStrategy extends FetchStrategy {
  @override
  String get id => 'cursor.web';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.web;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    final resolver = BrowserCookieResolver();
    return await resolver.hasPlausibleSession(UsageProvider.cursor);
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final resolver = BrowserCookieResolver();
    final cookies = await resolver.resolve(UsageProvider.cursor);
    if (cookies == null) {
      throw Exception('No Cursor cookies found');
    }

    final headers = {'Cookie': cookies.cookieHeader};

    // Fetch identity
    final meResponse = await http.get(
      Uri.parse('https://cursor.com/api/auth/me'),
      headers: headers,
    );
    if (meResponse.statusCode == 401) {
      throw Exception('Unauthorized - sign in to cursor.com');
    }

    String? accountEmail;
    if (meResponse.statusCode == 200) {
      final meJson = jsonDecode(meResponse.body) as Map<String, dynamic>;
      accountEmail = meJson['email'] as String?;
    }

    // Fetch usage summary
    final response = await http.get(
      Uri.parse('https://cursor.com/api/usage-summary'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch Cursor usage: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
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

    final totalPercentUsed = (json['totalPercentUsed'] as num?)?.toDouble();
    final billingCycleEnd = json['billingCycleEnd'] as String?;

    if (totalPercentUsed != null) {
      primary = RateWindow(
        usedPercent: totalPercentUsed,
        windowMinutes: null,
        resetsAt: billingCycleEnd != null
            ? DateTime.tryParse(billingCycleEnd)
            : null,
      );
    }

    return UsageSnapshot(
      primary: primary,
      updatedAt: DateTime.now(),
      identity: ProviderIdentitySnapshot(
        providerID: UsageProvider.cursor,
        accountEmail: accountEmail,
        loginMethod: 'cookie',
      ),
    );
  }
}
