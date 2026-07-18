import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'kimi_fetch_strategy.dart';

/// Kimi provider descriptor.
class KimiDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.kimi,
    metadata: const ProviderMetadata(
      id: UsageProvider.kimi,
      displayName: 'Kimi',
      sessionLabel: 'Usage',
      weeklyLabel: 'Requests',
      supportsOpus: false,
      supportsCredits: false,
      creditsHint: '',
      toggleTitle: 'Show Kimi usage',
      cliName: 'kimi',
      defaultEnabled: false,
      dashboardURL: 'https://kimi.moonshot.cn',
    ),
    branding: const ProviderBranding(
      iconStyle: 'kimi',
      iconResourceName: 'ProviderIcon-kimi',
      colorValue: 0xFF6236FF,
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'kimi',
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];

    final api = KimiAPIFetchStrategy();
    if (await api.isAvailable(context)) {
      strategies.add(api);
    }

    return strategies;
  }
}
