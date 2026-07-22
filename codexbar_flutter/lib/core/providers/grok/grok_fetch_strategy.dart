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

/// Grok web fetch strategy - uses browser cookies with gRPC-web protocol.
/// Direct port of Swift GrokWebFetchStrategy.
class GrokWebFetchStrategy extends FetchStrategy {
  @override
  String get id => 'grok.web';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.web;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async => true;

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final env = context.env.isEmpty ? Platform.environment : context.env;

    // Try manual cookie
    String? cookieHeader = env['GROK_COOKIE'];

    // Try browser cookies
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

    // Grok uses gRPC-web protocol
    final url = 'https://grok.com/grok_api_v2.GrokBuildBilling/GetGrokCreditsConfig';
    final headers = {
      'Cookie': cookieHeader,
      'Origin': 'https://grok.com',
      'Referer': 'https://grok.com/?_s=usage',
      'Accept': '*/*',
      'Content-Type': 'application/grpc-web+proto',
      'x-grpc-web': '1',
      'x-user-agent': 'connect-es/2.1.1',
      'User-Agent': 'CodexBar',
    };

    // gRPC-web requires POST with 5-byte empty frame
    final body = [0x00, 0x00, 0x00, 0x00, 0x00];

    DebugLogger.request('Grok', 'POST', url, headers: headers);
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );
      DebugLogger.response('Grok', url, response.statusCode, response.bodyBytes.length.toString());

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Grok session expired. Log in at grok.com');
      }
      if (response.statusCode != 200) {
        throw Exception('Grok API error: ${response.statusCode}');
      }

      // gRPC-web response is binary, try to parse
      if (response.bodyBytes.length > 5) {
        // Check for gRPC status in trailer
        final bodyStr = utf8.decode(response.bodyBytes, allowMalformed: true);
        DebugLogger.log('Grok', 'Response body (decoded): ${bodyStr.substring(0, bodyStr.length.clamp(0, 200))}');

        // Check for grpc-status:0 (success)
        if (bodyStr.contains('grpc-status:0')) {
          DebugLogger.log('Grok', 'gRPC status: success (grpc-status:0)');
          // The response is protobuf-encoded, we can't easily parse it
          // Return a success snapshot indicating connection works
          return ProviderFetchResult(
            usage: UsageSnapshot(
              updatedAt: DateTime.now(),
              identity: const ProviderIdentitySnapshot(
                providerID: UsageProvider.grok,
                loginMethod: 'connected (gRPC)',
              ),
            ),
            sourceLabel: 'web:grpc',
            strategyID: id,
            strategyKind: kind,
          );
        }

        // Try to find JSON in the response
        final jsonMatch = RegExp(r'\{.*\}').firstMatch(bodyStr);
        if (jsonMatch != null) {
          try {
            final json = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
            return _parseResponse(json);
          } catch (_) {}
        }
      }

      // Return cookie snapshot if we can't parse the response
      return ProviderFetchResult(
        usage: UsageSnapshot(
          updatedAt: DateTime.now(),
          identity: const ProviderIdentitySnapshot(
            providerID: UsageProvider.grok,
            loginMethod: 'cookie',
          ),
        ),
        sourceLabel: 'web:cookie',
        strategyID: id,
        strategyKind: kind,
      );
    } catch (e) {
      if (e is Exception && e.toString().contains('session expired')) rethrow;
      DebugLogger.error('Grok', 'Request failed', e);
      rethrow;
    }
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => false;

  ProviderFetchResult _parseResponse(Map<String, dynamic> json) {
    double? creditsPercent;
    String? planInfo;

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
        primary: creditsPercent != null ? RateWindow(usedPercent: creditsPercent) : null,
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
    throw Exception('Grok CLI fetch not yet implemented');
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => true;
}
