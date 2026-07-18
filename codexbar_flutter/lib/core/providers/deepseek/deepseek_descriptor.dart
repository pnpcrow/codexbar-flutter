import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'deepseek_fetch_strategy.dart';

class DeepSeekDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.deepseek,
    metadata: const ProviderMetadata(
      id: UsageProvider.deepseek,
      displayName: 'DeepSeek',
      sessionLabel: 'Balance',
      weeklyLabel: 'Balance',
      supportsOpus: false,
      supportsCredits: false,
      creditsHint: '',
      toggleTitle: 'Show DeepSeek usage',
      cliName: 'deepseek',
      defaultEnabled: false,
      dashboardURL: 'https://platform.deepseek.com/usage',
      statusLinkURL: 'https://status.deepseek.com',
    ),
    branding: const ProviderBranding(
      iconStyle: 'deepseek',
      iconResourceName: 'ProviderIcon-deepseek',
      colorValue: 0xFF527DF0,
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'deepseek',
    cliAliases: ['deep-seek', 'ds'],
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];
    final api = DeepSeekAPIFetchStrategy();
    if (await api.isAvailable(context)) {
      strategies.add(api);
    }
    return strategies;
  }
}
