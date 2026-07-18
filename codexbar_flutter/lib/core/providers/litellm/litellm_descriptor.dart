import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'litellm_fetch_strategy.dart';

/// LiteLLM provider descriptor.
class LiteLLMDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.litellm,
    metadata: const ProviderMetadata(
      id: UsageProvider.litellm,
      displayName: 'LiteLLM',
      sessionLabel: 'Spend',
      weeklyLabel: 'Requests',
      supportsOpus: false,
      supportsCredits: false,
      creditsHint: '',
      toggleTitle: 'Show LiteLLM usage',
      cliName: 'litellm',
      defaultEnabled: false,
      dashboardURL: null,
      statusPageURL: null,
    ),
    branding: const ProviderBranding(
      iconStyle: 'litellm',
      iconResourceName: 'ProviderIcon-litellm',
      colorValue: 0xFF4F46E5, // Indigo
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'litellm',
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];

    final api = LiteLLMAPIFetchStrategy();
    if (await api.isAvailable(context)) {
      strategies.add(api);
    }

    return strategies;
  }
}
