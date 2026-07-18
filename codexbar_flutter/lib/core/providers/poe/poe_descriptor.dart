import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'poe_fetch_strategy.dart';

/// Poe provider descriptor.
class PoeDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.poe,
    metadata: const ProviderMetadata(
      id: UsageProvider.poe,
      displayName: 'Poe',
      sessionLabel: 'Usage',
      weeklyLabel: 'Weekly',
      supportsOpus: false,
      supportsCredits: false,
      creditsHint: '',
      toggleTitle: 'Show Poe usage',
      cliName: 'poe',
      defaultEnabled: false,
      dashboardURL: 'https://poe.com/settings',
      statusPageURL: null,
    ),
    branding: const ProviderBranding(
      iconStyle: 'poe',
      iconResourceName: 'ProviderIcon-poe',
      colorValue: 0xFF8B5CF6,
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'poe',
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];
    final api = PoeFetchStrategy();
    if (await api.isAvailable(context)) {
      strategies.add(api);
    }
    return strategies;
  }
}
