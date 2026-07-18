

import 'package:http/http.dart' as http;

import '../../auth/browser_cookie_resolver.dart';
import '../../models/fetch_kind.dart';
import '../../models/fetch_result.dart';
import '../../models/provider_identity.dart';
import '../../models/rate_window.dart';
import '../../models/usage_provider.dart';
import '../../models/usage_snapshot.dart';
import '../fetch_strategy.dart';

/// Grok web fetch strategy.
/// Uses browser cookies to fetch from grok.com gRPC-web API.
class GrokWebFetchStrategy extends FetchStrategy {
  @override
  String get id => 'grok.web';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.web;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    final resolver = BrowserCookieResolver();
    return await resolver.hasPlausibleSession(UsageProvider.grok);
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final resolver = BrowserCookieResolver();
    final cookies = await resolver.resolve(UsageProvider.grok);
    if (cookies == null) {
      throw Exception('No Grok cookies found');
    }

    final headers = {
      'Cookie': cookies.cookieHeader,
      'Content-Type': 'application/proto',
    };

    // Fetch credits config via gRPC-web+proto
    final response = await http.post(
      Uri.parse('https://grok.com/grok_api_v2.GrokBuildBilling/GetGrokCreditsConfig'),
      headers: headers,
      body: [0x00, 0x00, 0x00, 0x00, 0x00],
    );

    if (response.statusCode == 401) {
      throw Exception('Unauthorized - sign in to grok.com');
    }
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch Grok credits: ${response.statusCode}');
    }

    // Parse binary protobuf response
    final snapshot = _parseGRPCWebResponse(response.bodyBytes);

    return ProviderFetchResult(
      usage: snapshot,
      sourceLabel: 'web',
      strategyID: id,
      strategyKind: kind,
    );
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => true;

  UsageSnapshot _parseGRPCWebResponse(List<int> bytes) {
    RateWindow? primary;

    // Simplified protobuf parsing - extract fixed32 fields
    // The response contains a usage percentage at a known offset
    final usedPercent = _extractUsagePercent(bytes);

    if (usedPercent != null) {
      primary = RateWindow(
        usedPercent: usedPercent,
        windowMinutes: null,
      );
    }

    return UsageSnapshot(
      primary: primary,
      updatedAt: DateTime.now(),
      identity: const ProviderIdentitySnapshot(
        providerID: UsageProvider.grok,
        loginMethod: 'cookie',
      ),
    );
  }

  /// Extract usage percentage from protobuf bytes.
  /// Looks for fixed32 values in the 0-100 range at expected field positions.
  double? _extractUsagePercent(List<int> bytes) {
    // Scan for field values that look like usage percentages
    for (var i = 0; i < bytes.length - 4; i++) {
      // Look for varint-encoded field tags followed by percentage values
      if (bytes[i] == 0x0D && i + 4 < bytes.length) {
        // fixed32 field
        final value = bytes[i + 1] |
            (bytes[i + 2] << 8) |
            (bytes[i + 3] << 16) |
            (bytes[i + 4] << 24);
        if (value >= 0 && value <= 100) {
          return value.toDouble();
        }
      }
    }
    return null;
  }
}
