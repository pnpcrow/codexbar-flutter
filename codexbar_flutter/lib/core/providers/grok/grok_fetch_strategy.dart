import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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

/// Grok credentials from ~/.grok/auth.json
class GrokCredentials {
  final String accessToken;
  final String? refreshToken;
  final String? email;
  final String? userId;
  final String? teamId;
  final DateTime? expiresAt;

  GrokCredentials({
    required this.accessToken,
    this.refreshToken,
    this.email,
    this.userId,
    this.teamId,
    this.expiresAt,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  factory GrokCredentials.fromJson(Map<String, dynamic> json) {
    // auth.json has a nested structure with the key as the domain
    final entries = json.entries.firstWhere(
      (e) => e.value is Map<String, dynamic>,
      orElse: () => MapEntry('', {}),
    );

    if (entries.value is! Map<String, dynamic>) {
      throw Exception('Invalid Grok auth.json format');
    }

    final data = entries.value as Map<String, dynamic>;
    return GrokCredentials(
      accessToken: data['key'] as String? ?? '',
      refreshToken: data['refresh_token'] as String?,
      email: data['email'] as String?,
      userId: data['user_id'] as String?,
      teamId: data['team_id'] as String?,
      expiresAt: data['expires_at'] != null
          ? DateTime.tryParse(data['expires_at'] as String)
          : null,
    );
  }
}

/// Grok web fetch strategy - uses auth.json or browser cookies.
class GrokWebFetchStrategy extends FetchStrategy {
  @override
  String get id => 'grok.web';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.web;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    // Check for auth.json
    final home = Platform.environment['HOME'] ?? '';
    final authFile = File('$home/.grok/auth.json');
    if (authFile.existsSync()) return true;

    // Check for browser cookies
    final resolver = BrowserCookieResolver();
    return await resolver.hasPlausibleSession(UsageProvider.grok);
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    // 1. Try auth.json credentials
    final credentials = _loadCredentials();
    if (credentials != null && !credentials.isExpired) {
      DebugLogger.log('Grok', 'Using credentials from ~/.grok/auth.json');
      return await _fetchWithCredentials(credentials);
    }

    // 2. Try browser cookies
    final resolver = BrowserCookieResolver();
    final cookies = await resolver.resolve(UsageProvider.grok);
    if (cookies != null) {
      DebugLogger.log('Grok', 'Using cookies from ${cookies.browser.displayName}');
      return await _fetchWithCookies(cookies.cookieHeader);
    }

    throw Exception('No Grok credentials found. Run `grok` to log in.');
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => false;

  GrokCredentials? _loadCredentials() {
    try {
      final home = Platform.environment['HOME'] ?? '';
      final authFile = File('$home/.grok/auth.json');
      if (!authFile.existsSync()) return null;

      final content = authFile.readAsStringSync();
      final json = jsonDecode(content) as Map<String, dynamic>;
      return GrokCredentials.fromJson(json);
    } catch (e) {
      DebugLogger.error('Grok', 'Failed to load auth.json', e);
      return null;
    }
  }

  Future<ProviderFetchResult> _fetchWithCredentials(GrokCredentials credentials) async {
    final url = 'https://grok.com/grok_api_v2.GrokBuildBilling/GetGrokCreditsConfig';
    final headers = {
      'Authorization': 'Bearer ${credentials.accessToken}',
      'Accept': '*/*',
      'Content-Type': 'application/grpc-web+proto',
      'x-grpc-web': '1',
      'x-user-agent': 'connect-es/2.1.1',
      'Origin': 'https://grok.com',
      'Referer': 'https://grok.com/?_s=usage',
    };

    final body = [0x00, 0x00, 0x00, 0x00, 0x00];

    DebugLogger.request('Grok', 'POST', url, headers: headers);
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );
      DebugLogger.response('Grok', url, response.statusCode, '${response.bodyBytes.length} bytes');

      if (response.statusCode == 200 && response.bodyBytes.length > 5) {
        final bodyStr = utf8.decode(response.bodyBytes, allowMalformed: true);
        if (bodyStr.contains('grpc-status:0')) {
          DebugLogger.log('Grok', 'gRPC success, parsing protobuf');

          // Parse gRPC-web response for usage data
          final parsed = _parseGRPCWebResponse(response.bodyBytes);

          return ProviderFetchResult(
            usage: UsageSnapshot(
              primary: parsed.percent != null
                  ? RateWindow(
                      usedPercent: parsed.percent!,
                      resetsAt: parsed.resetsAt,
                    )
                  : null,
              updatedAt: DateTime.now(),
              identity: ProviderIdentitySnapshot(
                providerID: UsageProvider.grok,
                accountEmail: credentials.email,
                accountOrganization: credentials.teamId,
                loginMethod: credentials.email ?? 'oauth',
              ),
            ),
            sourceLabel: 'oauth',
            strategyID: id,
            strategyKind: kind,
          );
        }
      }
    } catch (e) {
      DebugLogger.error('Grok', 'gRPC request failed', e);
    }

    // Fallback: return identity-only snapshot
    return ProviderFetchResult(
      usage: UsageSnapshot(
        updatedAt: DateTime.now(),
        identity: ProviderIdentitySnapshot(
          providerID: UsageProvider.grok,
          accountEmail: credentials.email,
          accountOrganization: credentials.teamId,
          loginMethod: credentials.email ?? 'oauth',
        ),
      ),
      sourceLabel: 'oauth:identity',
      strategyID: id,
      strategyKind: kind,
    );
  }

  /// Parse gRPC-web response to extract usage percent and reset time.
  /// Matches Swift GrokWebBillingFetcher.parseGRPCWebResponse logic.
  ({double? percent, DateTime? resetsAt}) _parseGRPCWebResponse(List<int> data) {
    // Extract gRPC-web data frames
    final payloads = _grpcWebDataFrames(data);
    if (payloads.isEmpty) return (percent: null, resetsAt: null);

    // Scan for protobuf fields
    final fixed32Fields = <({List<int> path, double value})>[];
    final varintFields = <({List<int> path, int value})>[];

    for (final payload in payloads) {
      _scanProtobuf(payload, [], fixed32Fields, varintFields);
    }

    // Find usage percent: fixed32 fields with value 0-100
    double? percent;
    for (final field in fixed32Fields) {
      if (field.path.isNotEmpty &&
          field.path.last == 1 &&
          field.value.isFinite &&
          field.value >= 0 &&
          field.value <= 100) {
        if (percent == null || field.value < percent) {
          percent = field.value;
        }
      }
    }

    // Find reset time: varint fields with Unix timestamp
    DateTime? resetsAt;
    final now = DateTime.now();
    for (final field in varintFields) {
      if (field.value >= 1700000000 && field.value <= 2100000000) {
        final date = DateTime.fromMillisecondsSinceEpoch(field.value * 1000);
        if (date.isAfter(now)) {
          if (resetsAt == null || date.isBefore(resetsAt)) {
            resetsAt = date;
          }
        }
      }
    }

    return (percent: percent, resetsAt: resetsAt);
  }

  /// Extract gRPC-web data frames from response.
  List<List<int>> _grpcWebDataFrames(List<int> data) {
    final frames = <List<int>>[];
    var offset = 0;

    while (offset < data.length) {
      if (offset + 5 > data.length) break;

      // gRPC-web frame: 1 byte flags + 4 bytes length
      final flags = data[offset];
      final length = (data[offset + 1] << 24) |
          (data[offset + 2] << 16) |
          (data[offset + 3] << 8) |
          data[offset + 4];

      if (length > 0 && offset + 5 + length <= data.length) {
        frames.add(data.sublist(offset + 5, offset + 5 + length));
      }
      offset += 5 + length;
    }

    // If no frames found, treat entire payload as one frame
    if (frames.isEmpty && data.length > 5) {
      frames.add(data.sublist(5));
    }

    return frames;
  }

  /// Simple protobuf scanner - extracts fixed32 and varint fields.
  void _scanProtobuf(
    List<int> data,
    List<int> path,
    List<({List<int> path, double value})> fixed32Fields,
    List<({List<int> path, int value})> varintFields,
  ) {
    var offset = 0;
    while (offset < data.length) {
      // Read tag (varint)
      final tagResult = _readVarint(data, offset);
      if (tagResult == null) break;
      offset = tagResult.offset;

      final fieldNumber = tagResult.value >> 3;
      final wireType = tagResult.value & 0x07;
      final currentPath = [...path, fieldNumber];

      switch (wireType) {
        case 0: // Varint
          final varResult = _readVarint(data, offset);
          if (varResult == null) return;
          offset = varResult.offset;
          varintFields.add((path: currentPath, value: varResult.value));
          break;
        case 1: // 64-bit
          if (offset + 8 > data.length) return;
          offset += 8;
          break;
        case 2: // Length-delimited
          final lenResult = _readVarint(data, offset);
          if (lenResult == null) return;
          offset = lenResult.offset;
          final len = lenResult.value;
          if (offset + len > data.length) return;
          // Try to parse as sub-message
          _scanProtobuf(data.sublist(offset, offset + len), currentPath, fixed32Fields, varintFields);
          offset += len;
          break;
        case 5: // 32-bit (fixed32)
          if (offset + 4 > data.length) return;
          final bytes = data.sublist(offset, offset + 4);
          final value = ByteData.sublistView(Uint8List.fromList(bytes)).getFloat32(0, Endian.little);
          fixed32Fields.add((path: currentPath, value: value));
          offset += 4;
          break;
        default:
          return; // Unknown wire type
      }
    }
  }

  /// Read a varint from data at offset.
  ({int value, int offset})? _readVarint(List<int> data, int offset) {
    var result = 0;
    var shift = 0;
    var pos = offset;

    while (pos < data.length) {
      final byte = data[pos];
      result |= (byte & 0x7F) << shift;
      pos++;
      if ((byte & 0x80) == 0) {
        return (value: result, offset: pos);
      }
      shift += 7;
      if (shift > 63) return null;
    }
    return null;
  }

  Future<ProviderFetchResult> _fetchWithCookies(String cookieHeader) async {
    final url = 'https://grok.com/grok_api_v2.GrokBuildBilling/GetGrokCreditsConfig';
    final headers = {
      'Cookie': cookieHeader,
      'Accept': '*/*',
      'Content-Type': 'application/grpc-web+proto',
      'x-grpc-web': '1',
      'Origin': 'https://grok.com',
      'Referer': 'https://grok.com/?_s=usage',
    };

    final body = [0x00, 0x00, 0x00, 0x00, 0x00];

    DebugLogger.request('Grok', 'POST', url, headers: headers);
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );
      DebugLogger.response('Grok', url, response.statusCode, '${response.bodyBytes.length} bytes');

      if (response.statusCode == 200 && response.bodyBytes.length > 5) {
        final bodyStr = utf8.decode(response.bodyBytes, allowMalformed: true);
        if (bodyStr.contains('grpc-status:0')) {
          DebugLogger.log('Grok', 'gRPC success via cookies');
          return ProviderFetchResult(
            usage: UsageSnapshot(
              updatedAt: DateTime.now(),
              identity: const ProviderIdentitySnapshot(
                providerID: UsageProvider.grok,
                loginMethod: 'cookie',
              ),
            ),
            sourceLabel: 'web:grpc',
            strategyID: id,
            strategyKind: kind,
          );
        }
      }
    } catch (e) {
      DebugLogger.error('Grok', 'gRPC cookie request failed', e);
    }

    throw Exception('Grok web fetch failed');
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
    // Grok CLI doesn't have a direct usage command
    // Fall back to web strategy
    throw Exception('Grok CLI usage fetch not available. Use web instead.');
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => true;
}
