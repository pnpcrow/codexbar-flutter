import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'kimik2_fetch_strategy.dart';

/// Kimi K2 provider descriptor.
class KimiK2Descriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.kimik2,
    metadata: const ProviderMetadata(
      id: UsageProvider.kimik2,
      displayName: 'Kimi K2',
      sessionLabel: 'Usage',
      weeklyLabel: 'Requests',
      supportsOpus: false,
      supportsCredits: false,
      creditsHint: '',
      toggleTitle: 'Show Kimi K2 usage',
      cliName: 'kimik2',
      defaultEnabled: false,
      dashboardURL: 'https://platform.moonshot.cn',
    ),
    branding: const ProviderBranding(
      iconStyle: 'kimik2',
      iconResourceName: 'ProviderIcon-kimik2',
      colorValue: 0xFF4A90D9,
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'kimik2',
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];

    final api = KimiK2APIFetchStrategy();
    if (await api.isAvailable(context)) {
      strategies.add(api);
    }

    return strategies;
  }
}
