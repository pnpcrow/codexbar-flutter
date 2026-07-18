import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'mistral_fetch_strategy.dart';

/// Mistral provider descriptor.
/// Direct port of Swift MistralProviderDescriptor.
class MistralDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.mistral,
    metadata: const ProviderMetadata(
      id: UsageProvider.mistral,
      displayName: 'Mistral',
      sessionLabel: 'Vibe',
      weeklyLabel: 'Credits',
      supportsOpus: false,
      supportsCredits: true,
      creditsHint: 'Credits',
      toggleTitle: 'Show Mistral usage',
      cliName: 'mistral',
      defaultEnabled: false,
      dashboardURL: 'https://console.mistral.ai/billing/',
      statusPageURL: 'https://status.mistral.ai',
    ),
    branding: const ProviderBranding(
      iconStyle: 'mistral',
      iconResourceName: 'ProviderIcon-mistral',
      colorValue: 0xFFFF500F, // RGB(255, 80, 15)
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'mistral',
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];

    final web = MistralWebFetchStrategy();
    if (await web.isAvailable(context)) {
      strategies.add(web);
    }

    return strategies;
  }
}
