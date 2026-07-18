import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'elevenlabs_fetch_strategy.dart';

/// ElevenLabs provider descriptor.
class ElevenLabsDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.elevenlabs,
    metadata: const ProviderMetadata(
      id: UsageProvider.elevenlabs,
      displayName: 'ElevenLabs',
      sessionLabel: 'Usage',
      weeklyLabel: 'Weekly',
      supportsOpus: false,
      supportsCredits: false,
      creditsHint: '',
      toggleTitle: 'Show ElevenLabs usage',
      cliName: 'elevenlabs',
      defaultEnabled: false,
      dashboardURL: 'https://elevenlabs.io/subscription',
      statusPageURL: 'https://status.elevenlabs.io',
    ),
    branding: const ProviderBranding(
      iconStyle: 'elevenlabs',
      iconResourceName: 'ProviderIcon-elevenlabs',
      colorValue: 0xFF000000, // Black
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'elevenlabs',
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];

    final api = ElevenLabsAPIFetchStrategy();
    if (await api.isAvailable(context)) {
      strategies.add(api);
    }

    return strategies;
  }
}
