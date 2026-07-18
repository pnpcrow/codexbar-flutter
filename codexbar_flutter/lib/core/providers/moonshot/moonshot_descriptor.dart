import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'moonshot_fetch_strategy.dart';

class MoonshotDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.moonshot,
    metadata: const ProviderMetadata(
      id: UsageProvider.moonshot,
      displayName: 'Moonshot / Kimi API',
      sessionLabel: 'Balance',
      weeklyLabel: 'Balance',
      supportsOpus: false,
      supportsCredits: false,
      creditsHint: '',
      toggleTitle: 'Show Moonshot / Kimi API balance',
      cliName: 'moonshot',
      defaultEnabled: false,
      dashboardURL: 'https://platform.moonshot.ai/console/account',
    ),
    branding: const ProviderBranding(
      iconStyle: 'kimi',
      iconResourceName: 'ProviderIcon-kimi',
      colorValue: 0xFF205DEB,
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'moonshot',
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];
    final api = MoonshotAPIFetchStrategy();
    if (await api.isAvailable(context)) {
      strategies.add(api);
    }
    return strategies;
  }
}
