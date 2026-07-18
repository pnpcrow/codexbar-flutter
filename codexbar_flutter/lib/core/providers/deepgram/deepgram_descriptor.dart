import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'deepgram_fetch_strategy.dart';

/// Deepgram provider descriptor.
class DeepgramDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.deepgram,
    metadata: const ProviderMetadata(
      id: UsageProvider.deepgram,
      displayName: 'Deepgram',
      sessionLabel: 'Usage',
      weeklyLabel: 'Requests',
      supportsOpus: false,
      supportsCredits: false,
      creditsHint: '',
      toggleTitle: 'Show Deepgram usage',
      cliName: 'deepgram',
      defaultEnabled: false,
      dashboardURL: 'https://console.deepgram.com',
    ),
    branding: const ProviderBranding(
      iconStyle: 'deepgram',
      iconResourceName: 'ProviderIcon-deepgram',
      colorValue: 0xFF13EF9B,
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'deepgram',
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];

    final api = DeepgramAPIFetchStrategy();
    if (await api.isAvailable(context)) {
      strategies.add(api);
    }

    return strategies;
  }
}
