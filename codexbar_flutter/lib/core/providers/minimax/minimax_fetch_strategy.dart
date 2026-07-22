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

/// MiniMax web fetch strategy - uses browser cookies.
/// Direct port of Swift MiniMaxCodingPlanFetchStrategy.
class MiniMaxWebFetchStrategy extends FetchStrategy {
  @override
  String get id => 'minimax.web';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.web;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async => true;

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final env = context.env.isEmpty ? Platform.environment : context.env;

    // Try manual cookie from environment
    String? cookieHeader = env['MINIMAX_COOKIE'];

    // Try browser cookies
    if (cookieHeader == null || cookieHeader.isEmpty) {
      DebugLogger.log('MiniMax', 'Trying browser cookie resolver...');
      final resolver = BrowserCookieResolver();
      final cookies = await resolver.resolve(UsageProvider.minimax);
      cookieHeader = cookies?.cookieHeader;
      if (cookies != null) {
        DebugLogger.log('MiniMax', 'Got cookies from ${cookies.browser.displayName}');
      }
    }

    if (cookieHeader == null || cookieHeader.isEmpty) {
      throw Exception('No MiniMax cookies found. Log in at platform.minimax.io');
    }

    // Extract _token from cookies as Bearer token
    String? bearerToken = env['MINIMAX_API_TOKEN'];
    if (bearerToken == null || bearerToken.isEmpty) {
      final tokenMatch = RegExp(r'_token=([^;]+)').firstMatch(cookieHeader);
      if (tokenMatch != null) {
        bearerToken = tokenMatch.group(1);
        DebugLogger.log('MiniMax', 'Extracted _token as Bearer token');
      }
    }

    // 1. Try HTML page (primary method in original CodexBar)
    final htmlResult = await _fetchCodingPlanHTML(cookieHeader, bearerToken, env);
    if (htmlResult != null) return htmlResult;

    // 2. Try remains API endpoints
    final remainsResult = await _fetchRemains(cookieHeader, bearerToken, env);
    if (remainsResult != null) return remainsResult;

    // Return cookie snapshot if no data received
    // (API needs MINIMAX_API_TOKEN, cookies alone insufficient)
    return ProviderFetchResult(
      usage: UsageSnapshot(
        updatedAt: DateTime.now(),
        identity: const ProviderIdentitySnapshot(
          providerID: UsageProvider.minimax,
          loginMethod: 'Set MINIMAX_API_TOKEN for usage data',
        ),
      ),
      sourceLabel: 'web:cookie-only',
      strategyID: id,
      strategyKind: kind,
    );
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => false;

  Future<ProviderFetchResult?> _fetchCodingPlanHTML(
    String cookieHeader,
    String? bearerToken,
    Map<String, String> env,
  ) async {
    final url = 'https://platform.minimax.io/user-center/payment/coding-plan?cycle_type=3';
    final headers = <String, String>{
      'Cookie': cookieHeader,
      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
      'Accept-Language': 'en-US,en;q=0.9',
      'Origin': 'https://platform.minimax.io',
      'Referer': 'https://platform.minimax.io/user-center/payment/coding-plan',
    };
    if (bearerToken != null && bearerToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $bearerToken';
    }

    DebugLogger.request('MiniMax', 'GET', url, headers: headers);
    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      DebugLogger.response('MiniMax', url, response.statusCode, '${response.body.length} chars');

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('MiniMax session expired. Log in at platform.minimax.io');
      }
      if (response.statusCode != 200) return null;

      final contentType = response.headers['content-type'] ?? '';

      // If JSON response, parse directly
      if (contentType.contains('application/json')) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return _parseJsonResponse(json);
      }

      // If HTML, look for __NEXT_DATA__ embedded JSON
      final html = response.body;
      if (html.contains('__NEXT_DATA__')) {
        DebugLogger.log('MiniMax', 'Found __NEXT_DATA__ in HTML');
        final match = RegExp(r'<script id="__NEXT_DATA__"[^>]*>(.*?)</script>').firstMatch(html);
        if (match != null) {
          try {
            final json = jsonDecode(match.group(1)!) as Map<String, dynamic>;
            return _parseNextData(json);
          } catch (e) {
            DebugLogger.error('MiniMax', 'Failed to parse __NEXT_DATA__', e);
          }
        }
      }

      // Check if signed out
      if (html.contains('sign-in') || html.contains('login')) {
        DebugLogger.log('MiniMax', 'Looks signed out');
        return null;
      }

      return null;
    } catch (e) {
      if (e is Exception && e.toString().contains('session expired')) rethrow;
      DebugLogger.error('MiniMax', 'HTML fetch failed', e);
      return null;
    }
  }

  Future<ProviderFetchResult?> _fetchRemains(
    String cookieHeader,
    String? bearerToken,
    Map<String, String> env,
  ) async {
    final endpoints = [
      'https://platform.minimax.io/v1/token_plan/remains',
      'https://platform.minimax.io/v1/api/openplatform/coding_plan/remains',
    ];

    for (final url in endpoints) {
      final headers = <String, String>{
        'Cookie': cookieHeader,
        'Accept': 'application/json, text/plain, */*',
      };
      if (bearerToken != null && bearerToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $bearerToken';
      }

      DebugLogger.request('MiniMax', 'GET', url, headers: headers);
      try {
        final response = await http.get(Uri.parse(url), headers: headers);
        DebugLogger.response('MiniMax', url, response.statusCode, response.body);

        if (response.statusCode == 200) {
          final contentType = response.headers['content-type'] ?? '';
          if (contentType.contains('json')) {
            final json = jsonDecode(response.body) as Map<String, dynamic>;
            final result = _parseJsonResponse(json);
            if (result != null) return result;
          }
        }
      } catch (e) {
        DebugLogger.error('MiniMax', 'Remains fetch failed ($url)', e);
      }
    }

    return null;
  }

  ProviderFetchResult? _parseJsonResponse(Map<String, dynamic> json) {
    // Check for error
    final baseResp = json['base_resp'] as Map<String, dynamic>?;
    if (baseResp != null) {
      final statusCode = baseResp['status_code'] as int?;
      if (statusCode != null && statusCode != 0) {
        DebugLogger.log('MiniMax', 'API error: ${baseResp['status_msg']}');
        return null;
      }
    }

    // Parse usage data
    double? percent;
    String? planName;
    DateTime? resetsAt;

    final data = json['data'] ?? json;
    if (data is Map) {
      // Try coding_plan format
      final codingPlan = data['coding_plan'] ?? data['codingPlan'];
      if (codingPlan is Map) {
        percent = (codingPlan['usage_percent'] as num?)?.toDouble();
        planName = codingPlan['plan_name'] as String?;
      }

      // Try token_plan format
      final tokenPlan = data['token_plan'] ?? data['tokenPlan'];
      if (tokenPlan is Map) {
        final used = (tokenPlan['used'] as num?)?.toDouble() ?? 0;
        final total = (tokenPlan['total'] as num?)?.toDouble() ?? 1;
        percent = (used / total * 100).clamp(0, 100);
        planName = tokenPlan['plan_name'] as String?;
      }

      // Try services format (multi-service)
      final services = data['services'] as List?;
      if (services != null && services.isNotEmpty) {
        final first = services[0] as Map<String, dynamic>;
        percent = (first['usage_percent'] as num?)?.toDouble();
        planName = first['name'] as String?;
      }
    }

    if (percent == null) return null;

    return ProviderFetchResult(
      usage: UsageSnapshot(
        primary: RateWindow(usedPercent: percent, resetsAt: resetsAt),
        updatedAt: DateTime.now(),
        identity: ProviderIdentitySnapshot(
          providerID: UsageProvider.minimax,
          loginMethod: planName ?? 'cookie',
        ),
      ),
      sourceLabel: 'web',
      strategyID: id,
      strategyKind: kind,
    );
  }

  ProviderFetchResult? _parseNextData(Map<String, dynamic> json) {
    final props = json['props'] as Map<String, dynamic>?;
    final pageProps = props?['pageProps'] as Map<String, dynamic>?;
    if (pageProps == null) return null;

    // Look for usage data in pageProps
    final data = pageProps['data'] ?? pageProps;
    return _parseJsonResponse(data is Map<String, dynamic> ? data : {'data': data});
  }
}

/// MiniMax API token fetch strategy.
class MiniMaxAPIFetchStrategy extends FetchStrategy {
  @override
  String get id => 'minimax.api';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.apiToken;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    final env = context.env.isEmpty ? Platform.environment : context.env;
    return env['MINIMAX_API_TOKEN']?.trim().isNotEmpty == true;
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final env = context.env.isEmpty ? Platform.environment : context.env;
    final token = env['MINIMAX_API_TOKEN']?.trim();
    if (token == null || token.isEmpty) {
      throw Exception('MINIMAX_API_TOKEN not set');
    }

    // Try global then China
    for (final host in ['api.minimax.io', 'api.minimaxi.com']) {
      final url = 'https://$host/v1/token_plan/remains';
      DebugLogger.request('MiniMax', 'GET', url);

      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );
        DebugLogger.response('MiniMax', url, response.statusCode, response.body);

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          final baseResp = json['base_resp'] as Map<String, dynamic>?;
          if (baseResp?['status_code'] == 0) {
            return ProviderFetchResult(
              usage: _parseApiResponse(json),
              sourceLabel: 'api',
              strategyID: id,
              strategyKind: kind,
            );
          }
        }
      } catch (e) {
        DebugLogger.error('MiniMax', 'API failed ($host)', e);
      }
    }

    throw Exception('MiniMax API failed');
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => true;

  UsageSnapshot _parseApiResponse(Map<String, dynamic> json) {
    double? percent;
    String? planName;

    final data = json['data'] ?? json;
    if (data is Map) {
      final tokenPlan = data['token_plan'] ?? data['tokenPlan'];
      if (tokenPlan is Map) {
        final used = (tokenPlan['used'] as num?)?.toDouble() ?? 0;
        final total = (tokenPlan['total'] as num?)?.toDouble() ?? 1;
        percent = (used / total * 100).clamp(0, 100);
        planName = tokenPlan['plan_name'] as String?;
      }
    }

    return UsageSnapshot(
      primary: percent != null ? RateWindow(usedPercent: percent) : null,
      updatedAt: DateTime.now(),
      identity: ProviderIdentitySnapshot(
        providerID: UsageProvider.minimax,
        loginMethod: planName ?? 'api',
      ),
    );
  }
}
