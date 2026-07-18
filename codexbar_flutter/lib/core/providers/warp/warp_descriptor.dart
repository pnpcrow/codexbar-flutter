import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'warp_fetch_strategy.dart';

/// Warp provider descriptor.
class WarpDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.warp,
    metadata: const ProviderMetadata(
      id: UsageProvider.warp,
      displayName: 'Warp',
      sessionLabel: 'Usage',
      weeklyLabel: 'Weekly',
      supportsOpus: false,
      supportsCredits: false,
      creditsHint: '',
      toggleTitle: 'Show Warp usage',
      cliName: 'warp',
      defaultEnabled: false,
      dashboardURL: 'https://app.warp.dev/settings/billing',
      statusPageURL: null,
    ),
    branding: const ProviderBranding(
      iconStyle: 'warp',
      iconResourceName: 'ProviderIcon-warp',
      colorValue: 0xFF6C63FF,
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'warp',
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];
    final api = WarpFetchStrategy();
    if (await api.isAvailable(context)) {
      strategies.add(api);
    }
    return strategies;
  }
}
