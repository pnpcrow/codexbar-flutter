import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'llmproxy_fetch_strategy.dart';

/// LLM Proxy provider descriptor.
class LLMProxyDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.llmproxy,
    metadata: const ProviderMetadata(
      id: UsageProvider.llmproxy,
      displayName: 'LLM Proxy',
      sessionLabel: 'Usage',
      weeklyLabel: 'Requests',
      supportsOpus: false,
      supportsCredits: false,
      creditsHint: '',
      toggleTitle: 'Show LLM Proxy usage',
      cliName: 'llmproxy',
      defaultEnabled: false,
      dashboardURL: null,
      statusPageURL: null,
    ),
    branding: const ProviderBranding(
      iconStyle: 'llmproxy',
      iconResourceName: 'ProviderIcon-llmproxy',
      colorValue: 0xFF6366F1, // Indigo
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'llmproxy',
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];

    final api = LLMProxyAPIFetchStrategy();
    if (await api.isAvailable(context)) {
      strategies.add(api);
    }

    return strategies;
  }
}
