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

/// Manus web cookie fetch strategy.
class ManusWebFetchStrategy extends FetchStrategy {
  @override
  String get id => 'manus.web';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.web;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    final resolver = BrowserCookieResolver();
    return await resolver.hasPlausibleSession(UsageProvider.manus);
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final resolver = BrowserCookieResolver();
    final cookies = await resolver.resolve(UsageProvider.manus);
    if (cookies == null) {
      throw Exception('No Manus cookies found');
    }

    final response = await http.get(
      Uri.parse('https://manus.im/api/usage'),
      headers: {'Cookie': cookies.cookieHeader},
    );

    if (response.statusCode == 401) {
      throw Exception('Unauthorized - sign in to manus.im');
    }

    RateWindow? primary;
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['usage'] != null) {
        final usage = json['usage'] as Map<String, dynamic>;
        primary = RateWindow(
          usedPercent: (usage['percent_used'] as num?)?.toDouble() ?? 0,
          windowMinutes: usage['window_minutes'] as int?,
          resetsAt: usage['resets_at'] != null
              ? DateTime.parse(usage['resets_at'] as String)
              : null,
        );
      }
    }

    return ProviderFetchResult(
      usage: UsageSnapshot(
        primary: primary,
        updatedAt: DateTime.now(),
        identity: const ProviderIdentitySnapshot(
          providerID: UsageProvider.manus,
          loginMethod: 'cookie',
        ),
      ),
      sourceLabel: 'web',
      strategyID: id,
      strategyKind: kind,
    );
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => true;
}
