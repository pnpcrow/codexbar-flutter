import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'antigravity_fetch_strategy.dart';

/// Antigravity provider descriptor.
/// Supports local probe and CLI strategies.
class AntigravityDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.antigravity,
    metadata: const ProviderMetadata(
      id: UsageProvider.antigravity,
      displayName: 'Antigravity',
      sessionLabel: 'Gemini Models',
      weeklyLabel: 'Claude and GPT',
      supportsOpus: false,
      supportsCredits: false,
      toggleTitle: 'Show Antigravity usage (experimental)',
      cliName: 'antigravity',
      defaultEnabled: false,
      statusLinkURL: 'https://www.google.com/appsstatus/dashboard/products/npdyhgECDJ6tB66MxXyo/history',
    ),
    branding: const ProviderBranding(
      iconStyle: 'antigravity',
      iconResourceName: 'ProviderIcon-antigravity',
      colorValue: 0xFF60BA7E,
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'antigravity',
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];

    // 1. Local probe (check running Antigravity processes)
    strategies.add(AntigravityLocalFetchStrategy());

    // 2. CLI strategy (if agy binary is installed)
    final cli = AntigravityCLIFetchStrategy();
    if (await cli.isAvailable(context)) {
      strategies.add(cli);
    }

    return strategies;
  }
}
