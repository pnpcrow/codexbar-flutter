import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';

/// Codex provider descriptor.
/// Codex uses CLI (codex binary) for usage data.
class CodexDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.codex,
    metadata: const ProviderMetadata(
      id: UsageProvider.codex,
      displayName: 'Codex',
      sessionLabel: 'Session',
      weeklyLabel: 'Weekly',
      supportsOpus: false,
      supportsCredits: false,
      creditsHint: '',
      toggleTitle: 'Show Codex usage',
      cliName: 'codex',
      defaultEnabled: false,
      isPrimaryProvider: true,
      dashboardURL: 'https://chatgpt.com/codex/settings',
      statusPageURL: 'https://status.openai.com',
    ),
    branding: const ProviderBranding(
      iconStyle: 'codex',
      iconResourceName: 'ProviderIcon-codex',
      colorValue: 0xFF10A37F,
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'codex',
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    // Codex uses CLI binary - no web cookie fallback
    return <FetchStrategy>[];
  }
}
