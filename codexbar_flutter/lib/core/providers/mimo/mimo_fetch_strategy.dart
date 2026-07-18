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

/// MiMo web fetch strategy - uses browser cookies.
/// Direct port of Swift MiMoWebFetchStrategy.
class MiMoWebFetchStrategy extends FetchStrategy {
  @override
  String get id => 'mimo.web';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.web;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    // Always available - will try to get cookies in fetch()
    return true;
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    DebugLogger.log('MiMo', 'Web fetch started');

    // 1. Try manual cookie from environment
    final env = context.env.isEmpty ? Platform.environment : context.env;
    String? cookieHeader = env['MIMO_COOKIE'];

    // 2. Try browser cookie resolver
    if (cookieHeader == null || cookieHeader.isEmpty) {
      DebugLogger.log('MiMo', 'Trying browser cookie resolver...');
      final resolver = BrowserCookieResolver();
      final cookies = await resolver.resolve(UsageProvider.mimo);
      cookieHeader = cookies?.cookieHeader;
      if (cookies != null) {
        DebugLogger.log('MiMo', 'Got cookies from ${cookies.browser.displayName}');
      }
    }

    if (cookieHeader == null || cookieHeader.isEmpty) {
      throw Exception('No MiMo cookies found. Log in at platform.xiaomimimo.com');
    }

    // 3. Fetch usage from MiMo web API
    return await _fetchUsage(cookieHeader);
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) {
    // Fall back to local cache if web fails
    return true;
  }

  Future<ProviderFetchResult> _fetchUsage(String cookieHeader) async {
    final baseUrl = 'https://platform.xiaomimimo.com/api/v1';
    final headers = {
      'Cookie': cookieHeader,
      'Accept': 'application/json',
      'Origin': 'https://platform.xiaomimimo.com',
      'Referer': 'https://platform.xiaomimimo.com/#/console/balance',
    };

    // Fetch all three endpoints
    final responses = <String, Map<String, dynamic>>{};
    for (final path in ['balance', 'tokenPlan/detail', 'tokenPlan/usage']) {
      final url = '$baseUrl/$path';
      DebugLogger.request('MiMo', 'GET', url, headers: headers);
      try {
        final response = await http.get(Uri.parse(url), headers: headers);
        DebugLogger.response('MiMo', url, response.statusCode, response.body);

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          if (json['code'] == 0) {
            responses[path] = json;
            DebugLogger.log('MiMo', 'Got $path data');
          }
        } else if (response.statusCode == 401 || response.statusCode == 403) {
          throw Exception('MiMo session expired. Log in at platform.xiaomimimo.com');
        }
      } catch (e) {
        if (e is Exception && e.toString().contains('session expired')) rethrow;
        DebugLogger.error('MiMo', 'Failed to fetch $path', e);
      }
    }

    if (responses.isEmpty) {
      throw Exception('No MiMo data received');
    }

    // Parse responses
    return _parseResponses(responses);
  }

  ProviderFetchResult _parseResponses(Map<String, Map<String, dynamic>> responses) {
    double? usagePercent;
    double? balance;
    String? currency;
    String? planName;
    DateTime? periodEnd;
    int? usedTokens;
    int? limitTokens;

    // Parse balance
    final balanceData = responses['balance']?['data'];
    if (balanceData is Map) {
      balance = double.tryParse(balanceData['balance']?.toString() ?? '');
      currency = balanceData['currency'] as String?;
      DebugLogger.log('MiMo', 'Balance: $balance $currency');
    }

    // Parse plan detail
    final detailData = responses['tokenPlan/detail']?['data'];
    if (detailData is Map) {
      planName = detailData['planName'] as String?;
      final periodEndStr = detailData['currentPeriodEnd'] as String?;
      if (periodEndStr != null) {
        periodEnd = DateTime.tryParse(periodEndStr);
      }
      DebugLogger.log('MiMo', 'Plan: $planName, period ends: $periodEnd');
    }

    // Parse usage
    final usageData = responses['tokenPlan/usage']?['data'];
    if (usageData is Map) {
      final monthUsage = usageData['monthUsage'];
      if (monthUsage is Map) {
        usagePercent = (monthUsage['percent'] as num?)?.toDouble();
        final items = monthUsage['items'] as List?;
        if (items != null && items.isNotEmpty) {
          final firstItem = items[0] as Map;
          usedTokens = firstItem['used'] as int?;
          limitTokens = firstItem['limit'] as int?;
        }
      }
      DebugLogger.log('MiMo', 'Usage: $usagePercent, used: $usedTokens, limit: $limitTokens');
    }

    // Normalize percent (0-1 -> 0-100)
    if (usagePercent != null && usagePercent > 0 && usagePercent < 1) {
      usagePercent = usagePercent * 100;
    }

    // Build description
    final descParts = <String>[];
    if (planName != null) descParts.add(planName);
    if (balance != null) descParts.add('\$$balance ${currency ?? ""}');
    if (usedTokens != null && limitTokens != null) {
      final usedB = (usedTokens! / 1e9).toStringAsFixed(1);
      final limitB = (limitTokens! / 1e9).toStringAsFixed(0);
      descParts.add('$usedB/$limitB tokens');
    }

    return ProviderFetchResult(
      usage: UsageSnapshot(
        primary: usagePercent != null
            ? RateWindow(
                usedPercent: usagePercent,
                windowMinutes: null,
                resetsAt: periodEnd,
              )
            : null,
        updatedAt: DateTime.now(),
        identity: ProviderIdentitySnapshot(
          providerID: UsageProvider.mimo,
          loginMethod: descParts.isNotEmpty ? descParts.join(' | ') : 'cookie',
        ),
      ),
      sourceLabel: 'web',
      strategyID: id,
      strategyKind: kind,
    );
  }
}
