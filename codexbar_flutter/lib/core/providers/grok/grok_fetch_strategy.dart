import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../auth/browser_cookie_resolver.dart';
import '../../debug/debug_logger.dart';
import '../../models/fetch_kind.dart';
import '../../models/fetch_result.dart';
import '../../models/provider_identity.dart';
import '../../models/rate_window.dart';
import '../../models/usage_provider.dart';
import '../../models/usage_snapshot.dart';
import '../fetch_strategy.dart';

/// Grok web fetch strategy - uses browser cookies.
/// Direct port of Swift GrokWebFetchStrategy.
class GrokWebFetchStrategy extends FetchStrategy {
  @override
  String get id => 'grok.web';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.web;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    // Always available - will try to get cookies in fetch()
    return true;
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final env = context.env.isEmpty ? Platform.environment : context.env;

    // Try manual cookie from environment
    String? cookieHeader = env['GROK_COOKIE'];

    // If no manual cookie, try browser
    if (cookieHeader == null || cookieHeader.isEmpty) {
      DebugLogger.log('Grok', 'Trying browser cookie resolver...');
      final resolver = BrowserCookieResolver();
      final cookies = await resolver.resolve(UsageProvider.grok);
      cookieHeader = cookies?.cookieHeader;
      if (cookies != null) {
        DebugLogger.log('Grok', 'Got cookies from ${cookies.browser.displayName}');
      }
    }

    if (cookieHeader == null || cookieHeader.isEmpty) {
      throw Exception('No Grok cookies found. Log in at grok.com');
    }

    // Fetch billing info from Grok API
    final url = 'https://grok.com/grok_api_v2.GrokBuildBilling/GetGrokCreditsConfig';
    final headers = {
      'Cookie': cookieHeader,
      'Accept': 'application/json',
      'Origin': 'https://grok.com',
      'Referer': 'https://grok.com/?_s=usage',
    };

    DebugLogger.request('Grok', 'GET', url, headers: headers);
    final response = await http.get(Uri.parse(url), headers: headers);
    DebugLogger.response('Grok', url, response.statusCode, response.body);

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Grok session expired. Log in at grok.com');
    }
    if (response.statusCode != 200) {
      throw Exception('Grok API error: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return _parseResponse(json);
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => false;

  ProviderFetchResult _parseResponse(Map<String, dynamic> json) {
    // Parse Grok credits config response
    double? creditsPercent;
    String? planInfo;

    // The response structure may vary - try common patterns
    final data = json['data'] ?? json;
    if (data is Map) {
      final credits = data['credits'] ?? data['billing'];
      if (credits is Map) {
        final used = (credits['used'] as num?)?.toDouble() ?? 0;
        final total = (credits['total'] as num?)?.toDouble() ?? 1;
        creditsPercent = (used / total * 100).clamp(0, 100);
        planInfo = credits['plan'] as String?;
      }
    }

    return ProviderFetchResult(
      usage: UsageSnapshot(
        primary: creditsPercent != null
            ? RateWindow(usedPercent: creditsPercent)
            : null,
        updatedAt: DateTime.now(),
        identity: ProviderIdentitySnapshot(
          providerID: UsageProvider.grok,
          loginMethod: planInfo ?? 'cookie',
        ),
      ),
      sourceLabel: 'web',
      strategyID: id,
      strategyKind: kind,
    );
  }
}

/// Grok CLI fetch strategy - uses grok binary.
class GrokCLIFetchStrategy extends FetchStrategy {
  @override
  String get id => 'grok.cli';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.cli;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    try {
      final result = await Process.run('which', ['grok']);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    // TODO: Implement Grok CLI fetch
    throw Exception('Grok CLI fetch not yet implemented');
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => true;
}
