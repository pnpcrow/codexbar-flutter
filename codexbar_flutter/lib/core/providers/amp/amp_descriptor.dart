import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'amp_fetch_strategy.dart';

class AmpDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.amp,
    metadata: const ProviderMetadata(
      id: UsageProvider.amp,
      displayName: 'Amp',
      sessionLabel: 'Amp Free',
      weeklyLabel: 'Balance',
      supportsOpus: false,
      supportsCredits: true,
      creditsHint: 'Individual and workspace credit balances from Amp.',
      toggleTitle: 'Show Amp usage',
      cliName: 'amp',
      defaultEnabled: false,
      dashboardURL: 'https://ampcode.com/settings/usage',
    ),
    branding: const ProviderBranding(
      iconStyle: 'amp',
      iconResourceName: 'ProviderIcon-amp',
      colorValue: 0xFFDC2626,
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'amp',
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];
    final api = AmpAPIFetchStrategy();
    if (await api.isAvailable(context)) {
      strategies.add(api);
    }
    return strategies;
  }
}
