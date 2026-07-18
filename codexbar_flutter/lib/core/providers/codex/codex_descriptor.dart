import '../../debug/debug_logger.dart';
import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'codex_fetch_strategy.dart';

/// Codex provider descriptor.
/// Uses OAuth token from ~/.codex/auth.json to query ChatGPT API.
class CodexDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.codex,
    metadata: const ProviderMetadata(
      id: UsageProvider.codex,
      displayName: 'Codex',
      sessionLabel: 'Session',
      weeklyLabel: 'Weekly',
      supportsOpus: false,
      supportsCredits: true,
      creditsHint: 'Credits unavailable; keep Codex running to refresh.',
      toggleTitle: 'Show Codex usage',
      cliName: 'codex',
      defaultEnabled: true,
      isPrimaryProvider: true,
      dashboardURL: 'https://chatgpt.com/codex/settings/usage',
      statusPageURL: 'https://status.openai.com',
    ),
    branding: const ProviderBranding(
      iconStyle: 'codex',
      iconResourceName: 'ProviderIcon-codex',
      colorValue: 0xFF49A3B0,
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'codex',
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];

    // 1. OAuth strategy (reads from ~/.codex/auth.json)
    final oauth = CodexOAuthFetchStrategy();
    final oauthAvailable = await oauth.isAvailable(context);
    DebugLogger.log('Codex', 'OAuth available: $oauthAvailable');
    if (oauthAvailable) {
      strategies.add(oauth);
    }

    // 2. CLI strategy (if codex binary is installed)
    final cli = CodexCLIFetchStrategy();
    final cliAvailable = await cli.isAvailable(context);
    DebugLogger.log('Codex', 'CLI available: $cliAvailable');
    if (cliAvailable) {
      strategies.add(cli);
    }

    DebugLogger.log('Codex', 'Resolved ${strategies.length} strategies');
    return strategies;
  }
}
