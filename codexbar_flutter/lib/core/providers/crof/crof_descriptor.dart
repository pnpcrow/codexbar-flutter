import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'crof_fetch_strategy.dart';

/// Crof provider descriptor.
class CrofDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.crof,
    metadata: const ProviderMetadata(
      id: UsageProvider.crof,
      displayName: 'Crof',
      sessionLabel: 'Usage',
      weeklyLabel: 'Weekly',
      supportsOpus: false,
      supportsCredits: false,
      creditsHint: '',
      toggleTitle: 'Show Crof usage',
      cliName: 'crof',
      defaultEnabled: false,
      dashboardURL: 'https://crof.com/dashboard',
      statusPageURL: null,
    ),
    branding: const ProviderBranding(
      iconStyle: 'crof',
      iconResourceName: 'ProviderIcon-crof',
      colorValue: 0xFFF59E0B,
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'crof',
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];
    final api = CrofFetchStrategy();
    if (await api.isAvailable(context)) {
      strategies.add(api);
    }
    return strategies;
  }
}
