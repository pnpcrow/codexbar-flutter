import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'grok_fetch_strategy.dart';

/// Grok provider descriptor.
/// Supports CLI and web cookie strategies.
class GrokDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.grok,
    metadata: const ProviderMetadata(
      id: UsageProvider.grok,
      displayName: 'Grok',
      sessionLabel: 'Credits',
      weeklyLabel: 'On-demand',
      supportsOpus: false,
      supportsCredits: false,
      toggleTitle: 'Show Grok usage',
      cliName: 'grok',
      defaultEnabled: false,
      dashboardURL: 'https://grok.com/?_s=usage',
      statusLinkURL: 'https://status.x.ai',
    ),
    branding: const ProviderBranding(
      iconStyle: 'grok',
      iconResourceName: 'ProviderIcon-grok',
      colorValue: 0xFF10A37F,
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'grok',
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];

    // 1. CLI strategy (if grok binary is installed)
    final cli = GrokCLIFetchStrategy();
    if (await cli.isAvailable(context)) {
      strategies.add(cli);
    }

    // 2. Web cookie strategy
    strategies.add(GrokWebFetchStrategy());

    return strategies;
  }
}
