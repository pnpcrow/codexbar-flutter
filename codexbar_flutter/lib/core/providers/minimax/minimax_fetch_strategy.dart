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

/// MiniMax API fetch strategy - uses MINIMAX_API_TOKEN.
class MiniMaxAPIFetchStrategy extends FetchStrategy {
  @override
  String get id => 'minimax.api';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.apiToken;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    final env = context.env.isEmpty ? Platform.environment : context.env;
    final token = env['MINIMAX_API_TOKEN']?.trim();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final env = context.env.isEmpty ? Platform.environment : context.env;
    final token = env['MINIMAX_API_TOKEN']?.trim();
    if (token == null || token.isEmpty) {
      throw Exception('MINIMAX_API_TOKEN not set');
    }

    // Try global region first, then China
    for (final region in ['global', 'cn']) {
      final host = region == 'global' ? 'api.minimax.io' : 'api.minimaxi.com';
      final url = 'https://$host/v1/token_plan/remains';

      DebugLogger.request('MiniMax', 'GET', url);
      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'MM-API-Source': 'CodexBar',
          },
        );
        DebugLogger.response('MiniMax', url, response.statusCode, response.body);

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          return _parseResponse(json, 'api');
        } else if (response.statusCode == 401 || response.statusCode == 403) {
          if (region == 'global') continue; // Try China
          throw Exception('Invalid MiniMax API token');
        }
      } catch (e) {
        if (region == 'cn') rethrow;
        continue;
      }
    }

    throw Exception('MiniMax API failed');
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) {
    if (error.toString().contains('Invalid')) return true;
    if (error.toString().contains('404')) return true;
    return false;
  }

  ProviderFetchResult _parseResponse(Map<String, dynamic> json, String source) {
    // Parse MiniMax token plan response
    final baseResp = json['base_resp'] as Map<String, dynamic>?;
    if (baseResp != null) {
      final statusCode = baseResp['status_code'] as int?;
      if (statusCode != null && statusCode != 0) {
        throw Exception('MiniMax API error: ${baseResp['status_msg']}');
      }
    }

    // Parse usage data
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

    return ProviderFetchResult(
      usage: UsageSnapshot(
        primary: percent != null ? RateWindow(usedPercent: percent) : null,
        updatedAt: DateTime.now(),
        identity: ProviderIdentitySnapshot(
          providerID: UsageProvider.minimax,
          loginMethod: planName ?? 'api',
        ),
      ),
      sourceLabel: source,
      strategyID: id,
      strategyKind: kind,
    );
  }
}

/// MiniMax web fetch strategy - uses browser cookies.
class MiniMaxWebFetchStrategy extends FetchStrategy {
  @override
  String get id => 'minimax.web';

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
    String? cookieHeader = env['MINIMAX_COOKIE'];
    String? bearerToken = env['MINIMAX_API_TOKEN'];

    // If no manual cookie, try browser
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
      throw Exception('No MiniMax cookies found. Set MINIMAX_COOKIE or MINIMAX_API_TOKEN.');
    }

    // Extract _token from cookies to use as Bearer token
    String? authToken = bearerToken;
    if (authToken == null || authToken.isEmpty) {
      final tokenMatch = RegExp(r'_token=([^;]+)').firstMatch(cookieHeader);
      if (tokenMatch != null) {
        authToken = tokenMatch.group(1);
        DebugLogger.log('MiniMax', 'Extracted _token from cookies as Bearer token');
      }
    }

    // Build headers
    final headers = <String, String>{
      'Cookie': cookieHeader,
      'Accept': 'application/json',
    };
    if (authToken != null && authToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    // Try web endpoints
    final endpoints = [
      'https://platform.minimax.io/v1/token_plan/remains',
      'https://platform.minimax.io/user-center/payment/coding-plan?cycle_type=3',
    ];

    for (final url in endpoints) {
      DebugLogger.request('MiniMax', 'GET', url, headers: headers);
      try {
        final response = await http.get(Uri.parse(url), headers: headers);
        DebugLogger.response('MiniMax', url, response.statusCode, response.body);

        if (response.statusCode == 200) {
          final contentType = response.headers['content-type'] ?? '';
          if (contentType.contains('json')) {
            final json = jsonDecode(response.body) as Map<String, dynamic>;
            return _parseResponse(json, 'web');
          }
        }
      } catch (e) {
        DebugLogger.error('MiniMax', 'Request failed ($url)', e);
      }
    }

    throw Exception('No working MiniMax endpoint found');
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => false;

  ProviderFetchResult _parseResponse(Map<String, dynamic> json, String source) {
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

    return ProviderFetchResult(
      usage: UsageSnapshot(
        primary: percent != null ? RateWindow(usedPercent: percent) : null,
        updatedAt: DateTime.now(),
        identity: ProviderIdentitySnapshot(
          providerID: UsageProvider.minimax,
          loginMethod: planName ?? 'web',
        ),
      ),
      sourceLabel: source,
      strategyID: id,
      strategyKind: kind,
    );
  }
}
