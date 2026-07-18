import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'claude_fetch_strategy.dart';

/// Claude provider descriptor.
/// Direct port of Swift ClaudeProviderDescriptor.
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
      supportsCredits: false,
      creditsHint: '',
      toggleTitle: 'Show Claude Code usage',
      cliName: 'claude',
      defaultEnabled: false,
      isPrimaryProvider: true,
      usesAccountFallback: false,
      dashboardURL: 'https://console.anthropic.com/settings/billing',
      subscriptionDashboardURL: 'https://claude.ai/settings/usage',
      changelogURL: 'https://github.com/anthropics/claude-code/releases',
      statusPageURL: 'https://status.claude.com/',
    ),
    branding: const ProviderBranding(
      iconStyle: 'claude',
      iconResourceName: 'ProviderIcon-claude',
      colorValue: 0xFFCC7C5E, // RGB(204, 124, 94)
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'claude',
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];

    // 1. CLI strategy (preferred - faster)
    final cli = ClaudeCLIFetchStrategy();
    if (await cli.isAvailable(context)) {
      strategies.add(cli);
    }

    // 2. Web cookie strategy (fallback)
    final web = ClaudeWebFetchStrategy();
    if (await web.isAvailable(context)) {
      strategies.add(web);
    }

    return strategies;
  }
}
