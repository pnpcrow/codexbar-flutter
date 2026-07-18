# Provider Implementation Guide for Subagents

## Overview
각 프로바이더는 동일한 패턴을 따라 구현합니다. 이 가이드를 반드시 따르세요.

## File Structure
```
lib/core/providers/<provider_name>/
  ├── <provider_name>_descriptor.dart    # ProviderDescriptor 정의
  ├── <provider_name>_fetcher.dart       # API/CLI 페칭 로직
  └── <provider_name>_snapshot.dart      # 프로바이더별 스냅샷 변환
```

## Step 1: Create Provider Descriptor

```dart
// lib/core/providers/claude/claude_descriptor.dart
import '../../models/fetch_kind.dart';
import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'claude_fetch_strategy.dart';

class ClaudeDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.claude,
    metadata: const ProviderMetadata(
      id: UsageProvider.claude,
      displayName: 'Claude',
      sessionLabel: 'Session',
      weeklyLabel: 'Weekly',
      opusLabel: 'Sonnet',
      supportsOpus: true,
      toggleTitle: 'Show Claude Code usage',
      cliName: 'claude',
      dashboardURL: 'https://console.anthropic.com/settings/billing',
      statusPageURL: 'https://status.claude.com/',
    ),
    branding: const ProviderBranding(
      iconStyle: 'claude',
      iconResourceName: 'ProviderIcon-claude',
      colorValue: 0xFFCC7C5E, // RGB(204, 124, 94)
    ),
    pipeline: FetchPipeline(
      resolveStrategies: (context) async {
        final strategies = <FetchStrategy>[];
        // 1. CLI strategy (if available)
        final cli = ClaudeCLIFetchStrategy();
        if (await cli.isAvailable(context)) strategies.add(cli);
        // 2. Web cookie strategy
        final web = ClaudeWebFetchStrategy();
        if (await web.isAvailable(context)) strategies.add(web);
        return strategies;
      },
    ),
    cliName: 'claude',
  );
}
```

## Step 2: Implement Fetch Strategies

### CLI Strategy Pattern
```dart
class ClaudeCLIFetchStrategy extends FetchStrategy {
  @override
  String get id => 'claude.cli';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.cli;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    // Check if claude CLI is installed
    try {
      final result = await Process.run('which', ['claude']);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    // Run claude CLI and parse output
    final result = await Process.run('claude', ['usage', '--json']);
    if (result.exitCode != 0) {
      throw Exception('Claude CLI failed: ${result.stderr}');
    }
    final json = jsonDecode(result.stdout as String) as Map<String, dynamic>;
    final snapshot = _parseSnapshot(json);
    return ProviderFetchResult(
      usage: snapshot,
      sourceLabel: 'cli',
      strategyID: id,
      strategyKind: kind,
    );
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => true;
}
```

### Web Cookie Strategy Pattern
```dart
class ClaudeWebFetchStrategy extends FetchStrategy {
  @override
  String get id => 'claude.web';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.web;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    // Check if browser cookies are available
    final resolver = BrowserCookieResolver();
    return await resolver.hasPlausibleSession(UsageProvider.claude);
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final resolver = BrowserCookieResolver();
    final cookies = await resolver.resolve(UsageProvider.claude);
    if (cookies == null) throw Exception('No cookies found');

    // 1. Fetch organization info
    final orgResponse = await http.get(
      Uri.parse('https://claude.ai/api/organizations'),
      headers: {'Cookie': cookies.cookieHeader},
    );
    if (orgResponse.statusCode == 401) throw Exception('Unauthorized');
    final orgs = jsonDecode(orgResponse.body) as List<dynamic>;
    if (orgs.isEmpty) throw Exception('No organization found');
    final orgId = orgs[0]['uuid'] as String;

    // 2. Fetch usage data
    final usageResponse = await http.get(
      Uri.parse('https://claude.ai/api/organizations/$orgId/usage'),
      headers: {'Cookie': cookies.cookieHeader},
    );
    final usageJson = jsonDecode(usageResponse.body) as Map<String, dynamic>;
    final snapshot = _parseUsageResponse(usageJson, orgs[0]);

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
```

## Step 3: Parse API Response to UsageSnapshot

```dart
UsageSnapshot _parseUsageResponse(Map<String, dynamic> json, Map<String, dynamic> org) {
  // Parse rate windows from API response
  RateWindow? primary;
  RateWindow? secondary;

  if (json['rate_limit'] != null) {
    final rateLimit = json['rate_limit'] as Map<String, dynamic>;
    if (rateLimit['five_hour'] != null) {
      final fiveHour = rateLimit['five_hour'] as Map<String, dynamic>;
      primary = RateWindow(
        usedPercent: (fiveHour['used_percent'] as num).toDouble(),
        windowMinutes: 300, // 5 hours
        resetsAt: fiveHour['resets_at'] != null
            ? DateTime.parse(fiveHour['resets_at'] as String)
            : null,
      );
    }
    if (rateLimit['seven_day'] != null) {
      final sevenDay = rateLimit['seven_day'] as Map<String, dynamic>;
      secondary = RateWindow(
        usedPercent: (sevenDay['used_percent'] as num).toDouble(),
        windowMinutes: 10080, // 7 days
        resetsAt: sevenDay['resets_at'] != null
            ? DateTime.parse(sevenDay['resets_at'] as String)
            : null,
      );
    }
  }

  return UsageSnapshot(
    primary: primary,
    secondary: secondary,
    updatedAt: DateTime.now(),
    identity: ProviderIdentitySnapshot(
      providerID: UsageProvider.claude,
      accountEmail: org['email'] as String?,
      accountOrganization: org['name'] as String?,
      loginMethod: 'cookie',
    ),
  );
}
```

## Step 4: Register Provider in main.dart

```dart
// In main.dart or initialization code
final registry = ProviderRegistry();
registry.register(ClaudeDescriptor.descriptor);
registry.register(OpenAIDescriptor.descriptor);
// ... register all providers
```

## Checklist for Each Provider
- [ ] Create descriptor with correct metadata
- [ ] Implement at least one fetch strategy (CLI or Web or API)
- [ ] Parse API response to UsageSnapshot correctly
- [ ] Handle errors gracefully
- [ ] Register in ProviderRegistry
- [ ] Test with `flutter analyze` (no errors)

## Common API Patterns

### API Key-based (OpenAI, DeepSeek, etc.)
```
GET https://api.example.com/v1/usage
Authorization: Bearer $API_KEY
```

### Cookie-based (Claude, Cursor, etc.)
```
GET https://example.com/api/usage
Cookie: session_key=xxx; ...
```

### CLI-based (Codex, Claude CLI)
```
$ claude usage --json
$ codex usage --json
```
