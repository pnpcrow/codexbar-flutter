import '../../debug/debug_logger.dart';
import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'zai_fetch_strategy.dart';

/// Zai provider descriptor.
/// API-only provider - requires Z_AI_API_KEY.
class ZaiDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.zai,
    metadata: const ProviderMetadata(
      id: UsageProvider.zai,
      displayName: 'z.ai',
      sessionLabel: 'Tokens',
      weeklyLabel: 'MCP',
      opusLabel: '5-hour',
      supportsOpus: true,
      supportsCredits: false,
      toggleTitle: 'Show z.ai usage',
      cliName: 'zai',
      defaultEnabled: false,
      dashboardURL: 'https://z.ai/manage-apikey/coding-plan/personal/my-plan',
    ),
    branding: const ProviderBranding(
      iconStyle: 'zai',
      iconResourceName: 'ProviderIcon-zai',
      colorValue: 0xFFE85A6A,
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'zai',
    cliAliases: ['z.ai'],
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];

    // Zai is API-only - requires Z_AI_API_KEY
    final api = ZaiAPIFetchStrategy();
    final available = await api.isAvailable(context);
    DebugLogger.log('Zai', 'Resolving strategies, API key available: $available');

    if (available) {
      strategies.add(api);
      DebugLogger.log('Zai', 'Added API strategy');
    } else {
      DebugLogger.log('Zai', 'No API key found. Set Z_AI_API_KEY environment variable.');
    }

    return strategies;
  }
}
