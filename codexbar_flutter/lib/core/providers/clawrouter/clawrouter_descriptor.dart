import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'clawrouter_fetch_strategy.dart';

/// ClawRouter provider descriptor.
class ClawRouterDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.clawrouter,
    metadata: const ProviderMetadata(
      id: UsageProvider.clawrouter,
      displayName: 'ClawRouter',
      sessionLabel: 'Usage',
      weeklyLabel: 'Requests',
      supportsOpus: false,
      supportsCredits: false,
      creditsHint: '',
      toggleTitle: 'Show ClawRouter usage',
      cliName: 'clawrouter',
      defaultEnabled: false,
      dashboardURL: null,
      statusPageURL: null,
    ),
    branding: const ProviderBranding(
      iconStyle: 'clawrouter',
      iconResourceName: 'ProviderIcon-clawrouter',
      colorValue: 0xFFDC2626, // Red
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'clawrouter',
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];

    final api = ClawRouterAPIFetchStrategy();
    if (await api.isAvailable(context)) {
      strategies.add(api);
    }

    return strategies;
  }
}
