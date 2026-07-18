import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'grok_fetch_strategy.dart';

/// Grok provider descriptor.
/// Direct port of Swift GrokProviderDescriptor.
class GrokDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.grok,
    metadata: const ProviderMetadata(
      id: UsageProvider.grok,
      displayName: 'Grok',
      sessionLabel: 'Usage',
      weeklyLabel: 'Credits',
      supportsOpus: false,
      supportsCredits: true,
      creditsHint: 'Credits',
      toggleTitle: 'Show Grok usage',
      cliName: 'grok',
      defaultEnabled: false,
      dashboardURL: 'https://grok.com/settings/billing',
      statusPageURL: 'https://status.grok.com',
    ),
    branding: const ProviderBranding(
      iconStyle: 'grok',
      iconResourceName: 'ProviderIcon-grok',
      colorValue: 0xFF10A37F, // RGB(16, 163, 127)
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

    final web = GrokWebFetchStrategy();
    if (await web.isAvailable(context)) {
      strategies.add(web);
    }

    return strategies;
  }
}
