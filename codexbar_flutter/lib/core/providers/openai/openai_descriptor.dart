import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'openai_fetch_strategy.dart';

/// OpenAI provider descriptor.
/// Direct port of Swift OpenAIAPIProviderDescriptor.
class OpenAIDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.openai,
    metadata: const ProviderMetadata(
      id: UsageProvider.openai,
      displayName: 'OpenAI',
      sessionLabel: 'Spend',
      weeklyLabel: 'Requests',
      supportsOpus: false,
      supportsCredits: false,
      creditsHint: '',
      toggleTitle: 'Show OpenAI usage',
      cliName: 'openai',
      defaultEnabled: false,
      dashboardURL: 'https://platform.openai.com/usage',
      statusPageURL: 'https://status.openai.com',
    ),
    branding: const ProviderBranding(
      iconStyle: 'openai',
      iconResourceName: 'ProviderIcon-codex',
      colorValue: 0xFF0F8273, // RGB(15, 130, 115)
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'openai',
    cliAliases: ['openai-api'],
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];

    // API key strategy
    final api = OpenAIAPIFetchStrategy();
    if (await api.isAvailable(context)) {
      strategies.add(api);
    }

    return strategies;
  }
}
