import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'venice_fetch_strategy.dart';

/// Venice provider descriptor.
class VeniceDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.venice,
    metadata: const ProviderMetadata(
      id: UsageProvider.venice,
      displayName: 'Venice',
      sessionLabel: 'Usage',
      weeklyLabel: 'Weekly',
      supportsOpus: false,
      supportsCredits: false,
      creditsHint: '',
      toggleTitle: 'Show Venice usage',
      cliName: 'venice',
      defaultEnabled: false,
      dashboardURL: 'https://venice.ai/dashboard',
      statusPageURL: null,
    ),
    branding: const ProviderBranding(
      iconStyle: 'venice',
      iconResourceName: 'ProviderIcon-venice',
      colorValue: 0xFF10B981,
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'venice',
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];
    final api = VeniceFetchStrategy();
    if (await api.isAvailable(context)) {
      strategies.add(api);
    }
    return strategies;
  }
}
