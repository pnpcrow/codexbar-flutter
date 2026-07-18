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

/// Mistral web fetch strategy.
/// Uses browser cookies to fetch from admin.mistral.ai API.
class MistralWebFetchStrategy extends FetchStrategy {
  @override
  String get id => 'mistral.web';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.web;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    final resolver = BrowserCookieResolver();
    return await resolver.hasPlausibleSession(UsageProvider.mistral);
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final resolver = BrowserCookieResolver();
    final cookies = await resolver.resolve(UsageProvider.mistral);
    if (cookies == null) {
      throw Exception('No Mistral cookies found');
    }

    final headers = {'Cookie': cookies.cookieHeader};

    // Fetch credits balance
    final creditsResponse = await http.get(
      Uri.parse('https://admin.mistral.ai/api/billing/credits'),
      headers: headers,
    );
    if (creditsResponse.statusCode == 401) {
      throw Exception('Unauthorized - sign in to admin.mistral.ai');
    }

    if (creditsResponse.statusCode == 200) {
      final creditsJson =
          jsonDecode(creditsResponse.body) as Map<String, dynamic>;
      // Wallet and credit info available but not currently displayed
      creditsJson['walletAmount'];
      creditsJson['creditNotesAmount'];
      creditsJson['ongoingUsageBalance'];
    }

    // Fetch vibe usage
    final vibeInput = Uri.encodeComponent('{}');
    final vibeResponse = await http.get(
      Uri.parse(
        'https://console.mistral.ai/api-ui/trpc/billing.vibeUsage?batch=1&input=$vibeInput',
      ),
      headers: headers,
    );

    RateWindow? primary;
    if (vibeResponse.statusCode == 200) {
      final vibeData = jsonDecode(vibeResponse.body) as List<dynamic>;
      if (vibeData.isNotEmpty) {
        final result = vibeData[0] as Map<String, dynamic>;
        final data = result['result']?['data']?['json'] as Map<String, dynamic>?;
        if (data != null) {
          final usagePercentage =
              (data['usage_percentage'] as num?)?.toDouble();
          if (usagePercentage != null) {
            primary = RateWindow(
              usedPercent: usagePercentage.clamp(0, 100),
              windowMinutes: null,
              resetsAt: data['reset_at'] != null
                  ? DateTime.tryParse(data['reset_at'] as String)
                  : null,
            );
          }
        }
      }
    }

    final snapshot = UsageSnapshot(
      primary: primary,
      updatedAt: DateTime.now(),
      identity: const ProviderIdentitySnapshot(
        providerID: UsageProvider.mistral,
        loginMethod: 'cookie',
      ),
    );

    return ProviderFetchResult(
      usage: snapshot,
      sourceLabel: 'web',
      strategyID: id,
      strategyKind: kind,
    );
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => true;
}
