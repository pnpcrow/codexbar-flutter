import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'mimo_fetch_strategy.dart';

/// MiMo provider descriptor.
/// Direct port of Swift MiMoProviderDescriptor.
class MiMoDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.mimo,
    metadata: const ProviderMetadata(
      id: UsageProvider.mimo,
      displayName: 'Xiaomi MiMo',
      sessionLabel: 'Credits',
      weeklyLabel: 'Window',
      supportsOpus: false,
      supportsCredits: true,
      creditsHint: 'Token plan credits usage.',
      toggleTitle: 'Show Xiaomi MiMo token plan & balance',
      cliName: 'mimo',
      defaultEnabled: false,
      dashboardURL: 'https://platform.xiaomimimo.com/#/console/balance',
    ),
    branding: const ProviderBranding(
      iconStyle: 'mimo',
      iconResourceName: 'ProviderIcon-mimo',
      colorValue: 0xFFFF6900,
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'mimo',
    cliAliases: ['xiaomi-mimo'],
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    // MiMo only supports web (cookie-based) fetching
    return [MiMoWebFetchStrategy()];
  }
}
