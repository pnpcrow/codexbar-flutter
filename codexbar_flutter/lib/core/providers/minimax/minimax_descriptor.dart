import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
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

    final api = MiniMaxAPIFetchStrategy();
    if (await api.isAvailable(context)) {
      strategies.add(api);
    }

    return strategies;
  }
}
