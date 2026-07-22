import 'dart:io';
import '../../constants/app_constants.dart';
import '../../models/usage_snapshot.dart';
import '../../models/rate_window.dart';
import '../../models/provider_metadata.dart';
import '../../services/http_client.dart';
import '../../services/credential_store.dart';
import '../shared/provider_implementation.dart';
import '../shared/provider_registry.dart';

class ClaudeProviderDescriptor {
  static ProviderDescriptor get descriptor => ProviderDescriptor(
    id: UsageProvider.claude,
    metadata: const ProviderMetadata(
      id: 'claude',
      displayName: 'Claude',
      sessionLabel: '5-hour',
      weeklyLabel: 'Weekly',
      supportsCredits: true,
      creditsHint: 'Credits from Claude subscription',
      toggleTitle: 'Enable Claude',
      cliName: 'claude',
      defaultEnabled: true,
      isPrimaryProvider: true,
      dashboardURL: 'https://console.anthropic.com',
      statusPageURL: 'https://status.anthropic.com',
    ),
    implementation: ClaudeProviderImplementation(),
  );
}

class ClaudeProviderImplementation extends ProviderImplementation {
  @override
  UsageProvider get id => UsageProvider.claude;

  @override
  ProviderMetadata get metadata => ClaudeProviderDescriptor.descriptor.metadata;

  @override
  Future<UsageSnapshot?> fetchUsage(ProviderFetchContext context) async {
    final creds = CredentialStore();

    // Try OAuth token
    var oauthToken = context.bearerToken ?? await creds.readClaudeOAuthToken();
    oauthToken ??= creds.getOAuthToken('claude');
    oauthToken ??= creds.getEnvApiKey('claude');

    // Try web session cookie
    final sessionCookie = creds.getCookieHeader('claude');

    // Try Admin API key
    final adminKey = creds.getApiKey('claude') ?? creds.getEnvApiKey('claude');

    // Fetch from CLI first (fastest)
    final cliData = await ClaudeHttpClient.fetchFromCLI();
    if (cliData != null) return _parseCLIResponse(cliData);

    // Try HTTP sources
    final data = await ClaudeHttpClient.fetchUsage(
      oauthToken: oauthToken,
      sessionCookie: sessionCookie,
      adminApiKey: adminKey,
    );

    if (data != null) return _parseWebResponse(data);
    return null;
  }

  UsageSnapshot _parseCLIResponse(Map<String, dynamic> data) {
    RateWindow? primary;
    RateWindow? secondary;

    if (data['session'] != null) {
      final session = data['session'] as Map<String, dynamic>;
      primary = RateWindow(
        usedPercent: (session['used_percent'] as num?)?.toDouble() ?? 0,
        windowMinutes: session['window_minutes'] as int?,
        resetsAt: session['resets_at'] != null
            ? DateTime.tryParse(session['resets_at'] as String)
            : null,
        resetDescription: session['reset_description'] as String?,
      );
    }

    if (data['weekly'] != null) {
      final weekly = data['weekly'] as Map<String, dynamic>;
      secondary = RateWindow(
        usedPercent: (weekly['used_percent'] as num?)?.toDouble() ?? 0,
        windowMinutes: weekly['window_minutes'] as int?,
        resetsAt: weekly['resets_at'] != null
            ? DateTime.tryParse(weekly['resets_at'] as String)
            : null,
        resetDescription: weekly['reset_description'] as String?,
      );
    }

    return UsageSnapshot(
      primary: primary,
      secondary: secondary,
      updatedAt: DateTime.now(),
      identity: ProviderIdentitySnapshot(
        providerID: UsageProvider.claude.name,
        accountEmail: data['email'] as String?,
        loginMethod: 'CLI',
      ),
    );
  }

  UsageSnapshot _parseWebResponse(Map<String, dynamic> data) {
    RateWindow? primary;
    RateWindow? secondary;

    if (data['five_hour'] != null) {
      final fiveHour = data['five_hour'] as Map<String, dynamic>;
      primary = RateWindow(
        usedPercent: (fiveHour['utilization'] as num?)?.toDouble() ?? 0,
        windowMinutes: 300,
        resetsAt: fiveHour['resets_at'] != null
            ? DateTime.tryParse(fiveHour['resets_at'] as String)
            : null,
      );
    }

    if (data['seven_day'] != null) {
      final weekly = data['seven_day'] as Map<String, dynamic>;
      secondary = RateWindow(
        usedPercent: (weekly['utilization'] as num?)?.toDouble() ?? 0,
        windowMinutes: 10080,
        resetsAt: weekly['resets_at'] != null
            ? DateTime.tryParse(weekly['resets_at'] as String)
            : null,
      );
    }

    return UsageSnapshot(
      primary: primary,
      secondary: secondary,
      updatedAt: DateTime.now(),
      identity: ProviderIdentitySnapshot(
        providerID: UsageProvider.claude.name,
        accountEmail: data['email'] as String?,
        loginMethod: 'OAuth',
      ),
    );
  }

  @override
  Future<String?> detectVersion() async {
    try {
      final result = await Process.run('claude', ['--version']);
      if (result.exitCode == 0) return (result.stdout as String).trim();
    } catch (e) {}
    return null;
  }
}
