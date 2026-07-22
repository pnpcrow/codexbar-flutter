import 'dart:io';
import '../../constants/app_constants.dart';
import '../../models/usage_snapshot.dart';
import '../../models/rate_window.dart';
import '../../models/provider_metadata.dart';
import '../../services/http_client.dart';
import '../../services/credential_store.dart';
import '../shared/provider_implementation.dart';
import '../shared/provider_registry.dart';

class CodexProviderDescriptor {
  static ProviderDescriptor get descriptor => ProviderDescriptor(
    id: UsageProvider.codex,
    metadata: const ProviderMetadata(
      id: 'codex',
      displayName: 'Codex',
      sessionLabel: '5-hour',
      weeklyLabel: 'Weekly',
      supportsCredits: true,
      creditsHint: 'Credits from OpenAI Codex',
      toggleTitle: 'Enable Codex',
      cliName: 'codex',
      defaultEnabled: true,
      isPrimaryProvider: true,
      dashboardURL: 'https://platform.openai.com',
      statusPageURL: 'https://status.openai.com',
    ),
    implementation: CodexProviderImplementation(),
  );
}

class CodexProviderImplementation extends ProviderImplementation {
  @override
  UsageProvider get id => UsageProvider.codex;

  @override
  ProviderMetadata get metadata => CodexProviderDescriptor.descriptor.metadata;

  @override
  Future<UsageSnapshot?> fetchUsage(ProviderFetchContext context) async {
    final creds = CredentialStore();

    // Try OAuth token from file
    var accessToken = context.bearerToken ?? await creds.readCodexOAuthToken();
    accessToken ??= creds.getOAuthToken('codex');

    // Try API key
    final apiKey = context.apiKey ?? creds.getApiKey('codex') ?? creds.getEnvApiKey('openai');

    // Try CLI first
    final cliData = await CodexHttpClient.fetchFromCLI();
    if (cliData != null) return _parseCLIResponse(cliData);

    // Try HTTP
    final data = await CodexHttpClient.fetchUsage(
      accessToken: accessToken,
      apiKey: apiKey,
    );

    if (data != null) return _parseResponse(data);
    return null;
  }

  UsageSnapshot _parseCLIResponse(Map<String, dynamic> data) {
    return _parseResponse(data, loginMethod: 'CLI');
  }

  UsageSnapshot _parseResponse(Map<String, dynamic> data, {String loginMethod = 'OAuth'}) {
    RateWindow? primary;
    RateWindow? secondary;

    // Parse rate_limit structure
    if (data['rate_limit'] != null) {
      final rateLimit = data['rate_limit'] as Map<String, dynamic>;

      if (rateLimit['primary_window'] != null) {
        final pw = rateLimit['primary_window'] as Map<String, dynamic>;
        final resetAt = pw['reset_at'] as int?;
        primary = RateWindow(
          usedPercent: (pw['used_percent'] as num?)?.toDouble() ?? 0,
          windowMinutes: pw['limit_window_seconds'] != null
              ? (pw['limit_window_seconds'] as int) ~/ 60
              : 300,
          resetsAt: resetAt != null
              ? DateTime.fromMillisecondsSinceEpoch(resetAt * 1000)
              : null,
        );
      }

      if (rateLimit['secondary_window'] != null) {
        final sw = rateLimit['secondary_window'] as Map<String, dynamic>;
        final resetAt = sw['reset_at'] as int?;
        secondary = RateWindow(
          usedPercent: (sw['used_percent'] as num?)?.toDouble() ?? 0,
          windowMinutes: sw['limit_window_seconds'] != null
              ? (sw['limit_window_seconds'] as int) ~/ 60
              : 10080,
          resetsAt: resetAt != null
              ? DateTime.fromMillisecondsSinceEpoch(resetAt * 1000)
              : null,
        );
      }
    }

    // Parse legacy session/weekly structure
    if (primary == null && data['session'] != null) {
      final session = data['session'] as Map<String, dynamic>;
      primary = RateWindow(
        usedPercent: (session['used_percent'] as num?)?.toDouble() ?? 0,
        windowMinutes: session['window_minutes'] as int?,
        resetsAt: session['resets_at'] != null
            ? DateTime.tryParse(session['resets_at'] as String)
            : null,
      );
    }

    return UsageSnapshot(
      primary: primary,
      secondary: secondary,
      updatedAt: DateTime.now(),
      identity: ProviderIdentitySnapshot(
        providerID: UsageProvider.codex.name,
        accountEmail: data['email'] as String?,
        loginMethod: loginMethod,
      ),
    );
  }

  @override
  Future<String?> detectVersion() async {
    try {
      final result = await Process.run('codex', ['--version']);
      if (result.exitCode == 0) return (result.stdout as String).trim();
    } catch (e) {}
    return null;
  }
}
