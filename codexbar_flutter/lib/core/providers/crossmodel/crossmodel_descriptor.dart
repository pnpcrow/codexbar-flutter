import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'crossmodel_fetch_strategy.dart';

/// CrossModel provider descriptor.
class CrossModelDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.crossmodel,
    metadata: const ProviderMetadata(
      id: UsageProvider.crossmodel,
      displayName: 'Cross Model',
      sessionLabel: 'Usage',
      weeklyLabel: 'Requests',
      supportsOpus: false,
      supportsCredits: false,
      creditsHint: '',
      toggleTitle: 'Show Cross Model usage',
      cliName: 'crossmodel',
      defaultEnabled: false,
      dashboardURL: null,
      statusPageURL: null,
    ),
    branding: const ProviderBranding(
      iconStyle: 'crossmodel',
      iconResourceName: 'ProviderIcon-crossmodel',
      colorValue: 0xFF7C3AED, // Purple
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'crossmodel',
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];

    final api = CrossModelAPIFetchStrategy();
    if (await api.isAvailable(context)) {
      strategies.add(api);
    }

    return strategies;
  }
}
