import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'alibaba_fetch_strategy.dart';

/// Alibaba provider descriptor.
class AlibabaDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.alibaba,
    metadata: const ProviderMetadata(
      id: UsageProvider.alibaba,
      displayName: 'Alibaba',
      sessionLabel: 'Usage',
      weeklyLabel: 'Requests',
      supportsOpus: false,
      supportsCredits: false,
      creditsHint: '',
      toggleTitle: 'Show Alibaba usage',
      cliName: 'alibaba',
      defaultEnabled: false,
      dashboardURL: 'https://bailian.console.aliyun.com',
    ),
    branding: const ProviderBranding(
      iconStyle: 'alibaba',
      iconResourceName: 'ProviderIcon-alibaba',
      colorValue: 0xFFFF6A00,
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'alibaba',
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];

    final api = AlibabaAPIFetchStrategy();
    if (await api.isAvailable(context)) {
      strategies.add(api);
    }

    return strategies;
  }
}
