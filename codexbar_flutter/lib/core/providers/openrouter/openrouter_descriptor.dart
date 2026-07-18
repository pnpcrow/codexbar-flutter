import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'openrouter_fetch_strategy.dart';

class OpenRouterDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.openrouter,
    metadata: const ProviderMetadata(
      id: UsageProvider.openrouter,
      displayName: 'OpenRouter',
      sessionLabel: 'Credits',
      weeklyLabel: 'Usage',
      supportsOpus: false,
      supportsCredits: true,
      creditsHint: 'Credit balance from OpenRouter API',
      toggleTitle: 'Show OpenRouter usage',
      cliName: 'openrouter',
      defaultEnabled: false,
      dashboardURL: 'https://openrouter.ai/settings/credits',
      statusLinkURL: 'https://status.openrouter.ai',
    ),
    branding: const ProviderBranding(
      iconStyle: 'openrouter',
      iconResourceName: 'ProviderIcon-openrouter',
      colorValue: 0xFF6467F2,
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'openrouter',
    cliAliases: ['or'],
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];
    final api = OpenRouterAPIFetchStrategy();
    if (await api.isAvailable(context)) {
      strategies.add(api);
    }
    return strategies;
  }
}
