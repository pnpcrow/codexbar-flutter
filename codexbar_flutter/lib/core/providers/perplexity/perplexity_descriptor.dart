import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'perplexity_fetch_strategy.dart';

/// Perplexity provider descriptor.
class PerplexityDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.perplexity,
    metadata: const ProviderMetadata(
      id: UsageProvider.perplexity,
      displayName: 'Perplexity',
      sessionLabel: 'Usage',
      weeklyLabel: 'Requests',
      supportsOpus: false,
      supportsCredits: false,
      creditsHint: '',
      toggleTitle: 'Show Perplexity usage',
      cliName: 'perplexity',
      defaultEnabled: false,
      dashboardURL: 'https://www.perplexity.ai/settings/api',
    ),
    branding: const ProviderBranding(
      iconStyle: 'perplexity',
      iconResourceName: 'ProviderIcon-perplexity',
      colorValue: 0xFF1B8AFF,
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'perplexity',
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];

    final api = PerplexityAPIFetchStrategy();
    if (await api.isAvailable(context)) {
      strategies.add(api);
    }

    return strategies;
  }
}
