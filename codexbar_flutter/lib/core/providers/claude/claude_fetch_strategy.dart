import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../auth/browser_cookie_resolver.dart';
import '../../models/fetch_kind.dart';
import '../../models/fetch_result.dart';
import '../../models/provider_identity.dart';
import '../../models/rate_window.dart';
import '../../models/usage_provider.dart';
import '../../models/usage_snapshot.dart';
import '../fetch_strategy.dart';

/// Claude CLI fetch strategy.
/// Uses `claude` CLI to fetch usage data.
class ClaudeCLIFetchStrategy extends FetchStrategy {
  @override
  String get id => 'claude.cli';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.cli;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    try {
      final result = await Process.run('which', ['claude']);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    // Try to get usage from claude CLI
    try {
      final result = await Process.run('claude', ['usage', '--json']);
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

    // Fallback: parse from session files
    return _fetchFromSessionFiles();
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => true;

  UsageSnapshot _parseCLISnapshot(Map<String, dynamic> json) {
    RateWindow? primary;
    RateWindow? secondary;

    if (json['session'] != null) {
      final session = json['session'] as Map<String, dynamic>;
      primary = RateWindow(
        usedPercent: (session['used_percent'] as num?)?.toDouble() ?? 0,
        windowMinutes: session['window_minutes'] as int?,
        resetsAt: session['resets_at'] != null
            ? DateTime.parse(session['resets_at'] as String)
            : null,
      );
    }

    if (json['weekly'] != null) {
      final weekly = json['weekly'] as Map<String, dynamic>;
      secondary = RateWindow(
        usedPercent: (weekly['used_percent'] as num?)?.toDouble() ?? 0,
        windowMinutes: weekly['window_minutes'] as int?,
        resetsAt: weekly['resets_at'] != null
            ? DateTime.parse(weekly['resets_at'] as String)
            : null,
      );
    }

    return UsageSnapshot(
      primary: primary,
      secondary: secondary,
      updatedAt: DateTime.now(),
      identity: const ProviderIdentitySnapshot(
        providerID: UsageProvider.claude,
        loginMethod: 'cli',
      ),
    );
  }

  Future<ProviderFetchResult> _fetchFromSessionFiles() async {
    // Parse Claude session files from ~/.claude/projects/
    final homeDir = Platform.environment['HOME'] ?? '';
    final claudeDir = Directory('$homeDir/.claude/projects');

    if (!await claudeDir.exists()) {
      throw Exception('No Claude sessions found');
    }

    // Look for session files with usage data
    final sessions = <Map<String, dynamic>>[];
    await for (final entity in claudeDir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.json')) {
        try {
          final content = await entity.readAsString();
          final json = jsonDecode(content) as Map<String, dynamic>;
          if (json.containsKey('usage') || json.containsKey('rate_limit')) {
            sessions.add(json);
          }
        } catch (_) {}
      }
    }

    if (sessions.isEmpty) {
      throw Exception('No Claude usage logs found');
    }

    // Use the most recent session
    sessions.sort((a, b) {
      final aTime = a['timestamp'] as String? ?? '';
      final bTime = b['timestamp'] as String? ?? '';
      return bTime.compareTo(aTime);
    });

    return ProviderFetchResult(
      usage: _parseCLISnapshot(sessions.first),
      sourceLabel: 'cli:session-file',
      strategyID: id,
      strategyKind: kind,
    );
  }
}

/// Claude web cookie fetch strategy.
/// Uses browser cookies to fetch from claude.ai API.
class ClaudeWebFetchStrategy extends FetchStrategy {
  @override
  String get id => 'claude.web';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.web;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    final resolver = BrowserCookieResolver();
    return await resolver.hasPlausibleSession(UsageProvider.claude);
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final resolver = BrowserCookieResolver();
    final cookies = await resolver.resolve(UsageProvider.claude);
    if (cookies == null) {
      throw Exception('No Claude cookies found');
    }

    final headers = {'Cookie': cookies.cookieHeader};

    // 1. Fetch organization info
    final orgResponse = await http.get(
      Uri.parse('https://claude.ai/api/organizations'),
      headers: headers,
    );

    if (orgResponse.statusCode == 401) {
      throw Exception('Unauthorized - sign in to claude.ai');
    }
    if (orgResponse.statusCode != 200) {
      throw Exception('Failed to fetch organizations: ${orgResponse.statusCode}');
    }

    final orgs = jsonDecode(orgResponse.body) as List<dynamic>;
    if (orgs.isEmpty) {
      throw Exception('No Claude organization found');
    }

    final org = orgs[0] as Map<String, dynamic>;
    final orgId = org['uuid'] as String;

    // 2. Fetch usage data
    final usageResponse = await http.get(
      Uri.parse('https://claude.ai/api/organizations/$orgId/usage'),
      headers: headers,
    );

    if (usageResponse.statusCode != 200) {
      throw Exception('Failed to fetch usage: ${usageResponse.statusCode}');
    }

    final usageJson = jsonDecode(usageResponse.body) as Map<String, dynamic>;
    final snapshot = _parseUsageResponse(usageJson, org);

    return ProviderFetchResult(
      usage: snapshot,
      sourceLabel: 'web',
      strategyID: id,
      strategyKind: kind,
    );
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => true;

  UsageSnapshot _parseUsageResponse(
    Map<String, dynamic> json,
    Map<String, dynamic> org,
  ) {
    RateWindow? primary;
    RateWindow? secondary;
    RateWindow? tertiary;

    // Parse rate limits
    final rateLimit = json['rate_limit'] as Map<String, dynamic>?;

    if (rateLimit?['five_hour'] != null) {
      final fiveHour = rateLimit!['five_hour'] as Map<String, dynamic>;
      primary = RateWindow(
        usedPercent: (fiveHour['used_percent'] as num?)?.toDouble() ?? 0,
        windowMinutes: 300, // 5 hours
        resetsAt: fiveHour['resets_at'] != null
            ? DateTime.parse(fiveHour['resets_at'] as String)
            : null,
        isSyntheticPlaceholder: fiveHour['is_synthetic'] as bool? ?? false,
      );
    }

    if (rateLimit?['seven_day'] != null) {
      final sevenDay = rateLimit!['seven_day'] as Map<String, dynamic>;
      secondary = RateWindow(
        usedPercent: (sevenDay['used_percent'] as num?)?.toDouble() ?? 0,
        windowMinutes: 10080, // 7 days
        resetsAt: sevenDay['resets_at'] != null
            ? DateTime.parse(sevenDay['resets_at'] as String)
            : null,
      );
    }

    // Parse opus usage if available
    if (rateLimit?['opus'] != null) {
      final opus = rateLimit!['opus'] as Map<String, dynamic>;
      tertiary = RateWindow(
        usedPercent: (opus['used_percent'] as num?)?.toDouble() ?? 0,
        windowMinutes: opus['window_minutes'] as int?,
        resetsAt: opus['resets_at'] != null
            ? DateTime.parse(opus['resets_at'] as String)
            : null,
      );
    }

    return UsageSnapshot(
      primary: primary,
      secondary: secondary,
      tertiary: tertiary,
      updatedAt: DateTime.now(),
      identity: ProviderIdentitySnapshot(
        providerID: UsageProvider.claude,
        accountEmail: org['email'] as String?,
        accountOrganization: org['name'] as String?,
        loginMethod: 'cookie',
      ),
    );
  }
}
