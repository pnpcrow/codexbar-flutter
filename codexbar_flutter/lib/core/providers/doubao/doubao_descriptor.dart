import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'doubao_fetch_strategy.dart';

/// Doubao provider descriptor.
class DoubaoDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.doubao,
    metadata: const ProviderMetadata(
      id: UsageProvider.doubao,
      displayName: 'Doubao',
      sessionLabel: 'Usage',
      weeklyLabel: 'Weekly',
      supportsOpus: false,
      supportsCredits: false,
      creditsHint: '',
      toggleTitle: 'Show Doubao usage',
      cliName: 'doubao',
      defaultEnabled: false,
      dashboardURL: 'https://console.volcengine.com/ark/region:ark+cn-beijing/apiKey',
      statusPageURL: null,
    ),
    branding: const ProviderBranding(
      iconStyle: 'doubao',
      iconResourceName: 'ProviderIcon-doubao',
      colorValue: 0xFF00B4D8,
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'doubao',
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];
    final api = DoubaoFetchStrategy();
    if (await api.isAvailable(context)) {
      strategies.add(api);
    }
    return strategies;
  }
}
