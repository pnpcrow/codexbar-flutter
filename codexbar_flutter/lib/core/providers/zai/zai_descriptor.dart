import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'zai_fetch_strategy.dart';

class ZaiDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.zai,
    metadata: const ProviderMetadata(
      id: UsageProvider.zai,
      displayName: 'z.ai',
      sessionLabel: 'Tokens',
      weeklyLabel: 'MCP',
      opusLabel: '5-hour',
      supportsOpus: true,
      supportsCredits: false,
      creditsHint: '',
      toggleTitle: 'Show z.ai usage',
      cliName: 'zai',
      defaultEnabled: false,
      dashboardURL: 'https://z.ai/manage-apikey/coding-plan/personal/my-plan',
    ),
    branding: const ProviderBranding(
      iconStyle: 'zai',
      iconResourceName: 'ProviderIcon-zai',
      colorValue: 0xFFE85A6A,
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'zai',
    cliAliases: ['z.ai'],
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];
    final api = ZaiAPIFetchStrategy();
    if (await api.isAvailable(context)) {
      strategies.add(api);
    }
    return strategies;
  }
}
