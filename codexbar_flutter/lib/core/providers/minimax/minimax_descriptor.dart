import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import '../shared/provider_descriptors.dart';
import 'minimax_fetch_strategy.dart';

/// MiniMax provider descriptor.
class MiniMaxDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.minimax,
    metadata: const ProviderMetadata(
      id: UsageProvider.minimax,
      displayName: 'MiniMax',
      sessionLabel: 'Usage',
      weeklyLabel: 'Requests',
      supportsOpus: false,
      supportsCredits: false,
      creditsHint: '',
      toggleTitle: 'Show MiniMax usage',
      cliName: 'minimax',
      defaultEnabled: false,
      dashboardURL: 'https://platform.minimaxi.com',
    ),
    branding: const ProviderBranding(
      iconStyle: 'minimax',
      iconResourceName: 'ProviderIcon-minimax',
      colorValue: 0xFF00D4AA,
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'minimax',
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];

    // 1. API token strategy (if MINIMAX_API_TOKEN is set)
    final api = MiniMaxAPIFetchStrategy();
    if (await api.isAvailable(context)) {
      strategies.add(api);
    }

    // 2. Cookie strategy (always available as fallback)
    strategies.add(CookieFetchStrategy(
      provider: UsageProvider.minimax,
      apiDomain: 'api.minimax.chat',
    ));

    return strategies;
  }
}
