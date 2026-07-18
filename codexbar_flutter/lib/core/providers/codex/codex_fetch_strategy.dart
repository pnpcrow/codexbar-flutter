import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../debug/debug_logger.dart';
import '../../models/fetch_kind.dart' hide ProviderSourceMode;
import '../../models/fetch_result.dart';
import '../../models/provider_identity.dart';
import '../../models/rate_window.dart';
import '../../models/usage_provider.dart';
import '../../models/usage_snapshot.dart';
import '../fetch_strategy.dart';

/// Codex OAuth credentials from ~/.codex/auth.json
class CodexOAuthCredentials {
  final String accessToken;
  final String refreshToken;
  final String? idToken;
  final String? accountId;
  final DateTime? lastRefresh;

  CodexOAuthCredentials({
    required this.accessToken,
    required this.refreshToken,
    this.idToken,
    this.accountId,
    this.lastRefresh,
  });

  bool get needsRefresh {
    if (lastRefresh == null) return true;
    return DateTime.now().difference(lastRefresh!).inDays > 8;
  }

  factory CodexOAuthCredentials.fromJson(Map<String, dynamic> json) {
    // Tokens are nested inside 'tokens' object
    final tokens = json['tokens'] as Map<String, dynamic>? ?? json;
    return CodexOAuthCredentials(
      accessToken: tokens['access_token'] as String? ?? '',
      refreshToken: tokens['refresh_token'] as String? ?? '',
      idToken: tokens['id_token'] as String?,
      accountId: tokens['account_id'] as String?,
      lastRefresh: json['last_refresh'] != null
          ? DateTime.tryParse(json['last_refresh'] as String)
          : null,
    );
  }
}

/// Codex OAuth fetch strategy - reads tokens from ~/.codex/auth.json
class CodexOAuthFetchStrategy extends FetchStrategy {
  @override
  String get id => 'codex.oauth';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.oauth;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    final credentials = _loadCredentials();
    if (credentials == null) return false;
    return credentials.accessToken.isNotEmpty;
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final credentials = _loadCredentials();
    if (credentials == null || credentials.accessToken.isEmpty) {
      throw Exception('Codex auth.json not found or empty. Run `codex` to log in.');
    }

    DebugLogger.log('Codex', 'Using OAuth token from ~/.codex/auth.json');

    // Fetch usage from ChatGPT API
    final headers = {
      'Authorization': 'Bearer ${credentials.accessToken}',
      'Accept': 'application/json',
      'User-Agent': 'CodexBar',
    };

    if (credentials.accountId != null && credentials.accountId!.isNotEmpty) {
      headers['ChatGPT-Account-Id'] = credentials.accountId!;
    }

    const url = 'https://chatgpt.com/backend-api/wham/usage';
    DebugLogger.request('Codex', 'GET', url, headers: headers);

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      DebugLogger.response('Codex', url, response.statusCode, response.body);

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Codex OAuth token expired. Run `codex` to re-login.');
      }
      if (response.statusCode != 200) {
        throw Exception('Codex API error: ${response.statusCode}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final snapshot = _parseUsageResponse(json, credentials);

      return ProviderFetchResult(
        usage: snapshot,
        sourceLabel: 'oauth',
        strategyID: id,
        strategyKind: kind,
      );
    } catch (e) {
      DebugLogger.error('Codex', 'API request failed', e);
      rethrow;
    }
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) {
    // In auto mode, fall back to CLI if OAuth fails
    return context.sourceMode == ProviderSourceMode.auto;
  }

  CodexOAuthCredentials? _loadCredentials() {
    try {
      final home = Platform.environment['HOME'] ?? '';
      final authFile = File('$home/.codex/auth.json');
      DebugLogger.log('Codex', 'Looking for auth.json at: ${authFile.path}');

      if (!authFile.existsSync()) {
        DebugLogger.log('Codex', 'auth.json not found');
        return null;
      }

      final content = authFile.readAsStringSync();
      final json = jsonDecode(content) as Map<String, dynamic>;
      DebugLogger.log('Codex', 'auth.json keys: ${json.keys.toList()}');

      final credentials = CodexOAuthCredentials.fromJson(json);
      DebugLogger.log('Codex', 'Access token length: ${credentials.accessToken.length}');
      DebugLogger.log('Codex', 'Account ID: ${credentials.accountId}');

      return credentials;
    } catch (e) {
      DebugLogger.error('Codex', 'Failed to load auth.json', e);
      return null;
    }
  }

  UsageSnapshot _parseUsageResponse(Map<String, dynamic> json, CodexOAuthCredentials credentials) {
    RateWindow? primary;
    RateWindow? secondary;

    final rateLimit = json['rate_limit'] as Map<String, dynamic>?;
    if (rateLimit != null) {
      // Parse primary window
      final primaryWindow = rateLimit['primary_window'] as Map<String, dynamic>?;
      if (primaryWindow != null) {
        primary = _parseWindow(primaryWindow);
      }

      // Parse secondary window
      final secondaryWindow = rateLimit['secondary_window'] as Map<String, dynamic>?;
      if (secondaryWindow != null) {
        secondary = _parseWindow(secondaryWindow);
      }
    }

    // Parse credits
    final credits = json['credits'] as Map<String, dynamic>?;
    String? creditInfo;
    if (credits != null) {
      final balance = credits['balance'];
      if (balance != null) {
        creditInfo = 'Credits: $balance';
      }
    }

    return UsageSnapshot(
      primary: primary,
      secondary: secondary,
      updatedAt: DateTime.now(),
      identity: ProviderIdentitySnapshot(
        providerID: UsageProvider.codex,
        loginMethod: creditInfo ?? 'oauth',
      ),
    );
  }

  RateWindow? _parseWindow(Map<String, dynamic> json) {
    final usedPercent = (json['used_percent'] as num?)?.toDouble();
    if (usedPercent == null) return null;

    return RateWindow(
      usedPercent: usedPercent,
      windowMinutes: json['window_minutes'] as int?,
      resetsAt: json['resets_at'] != null
          ? DateTime.tryParse(json['resets_at'] as String)
          : null,
    );
  }
}

/// Codex CLI fetch strategy - uses codex binary via RPC
class CodexCLIFetchStrategy extends FetchStrategy {
  @override
  String get id => 'codex.cli';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.cli;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    try {
      final result = await Process.run('which', ['codex']);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    // Try to get usage from codex CLI
    try {
      final result = await Process.run('codex', ['usage', '--json']);
      if (result.exitCode == 0) {
        final json = jsonDecode(result.stdout as String) as Map<String, dynamic>;
        final snapshot = _parseCLISnapshot(json);
        return ProviderFetchResult(
          usage: snapshot,
          sourceLabel: 'cli',
          strategyID: id,
          strategyKind: kind,
        );
      }
    } catch (_) {}

    throw Exception('Codex CLI not available or no usage data');
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => false;

  UsageSnapshot _parseCLISnapshot(Map<String, dynamic> json) {
    RateWindow? primary;
    RateWindow? secondary;

    if (json['session'] != null) {
      final session = json['session'] as Map<String, dynamic>;
      primary = RateWindow(
        usedPercent: (session['used_percent'] as num?)?.toDouble() ?? 0,
        windowMinutes: session['window_minutes'] as int?,
        resetsAt: session['resets_at'] != null
            ? DateTime.tryParse(session['resets_at'] as String)
            : null,
      );
    }

    if (json['weekly'] != null) {
      final weekly = json['weekly'] as Map<String, dynamic>;
      secondary = RateWindow(
        usedPercent: (weekly['used_percent'] as num?)?.toDouble() ?? 0,
        windowMinutes: weekly['window_minutes'] as int?,
        resetsAt: weekly['resets_at'] != null
            ? DateTime.tryParse(weekly['resets_at'] as String)
            : null,
      );
    }

    return UsageSnapshot(
      primary: primary,
      secondary: secondary,
      updatedAt: DateTime.now(),
      identity: const ProviderIdentitySnapshot(
        providerID: UsageProvider.codex,
        loginMethod: 'cli',
      ),
    );
  }
}
