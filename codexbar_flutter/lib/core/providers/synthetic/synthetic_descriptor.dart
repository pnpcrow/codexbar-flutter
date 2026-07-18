import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'synthetic_fetch_strategy.dart';

class SyntheticDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.synthetic,
    metadata: const ProviderMetadata(
      id: UsageProvider.synthetic,
      displayName: 'Synthetic',
      sessionLabel: 'Five-hour quota',
      weeklyLabel: 'Weekly tokens',
      opusLabel: 'Search hourly',
      supportsOpus: true,
      supportsCredits: false,
      creditsHint: 'Weekly token quota regenerates continuously.',
      toggleTitle: 'Show Synthetic usage',
      cliName: 'synthetic',
      defaultEnabled: false,
    ),
    branding: const ProviderBranding(
      iconStyle: 'synthetic',
      iconResourceName: 'ProviderIcon-synthetic',
      colorValue: 0xFF141414,
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'synthetic',
    cliAliases: ['synthetic.new'],
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];
    final api = SyntheticAPIFetchStrategy();
    if (await api.isAvailable(context)) {
      strategies.add(api);
    }
    return strategies;
  }
}
