import 'dart:io';

import '../../auth/browser_cookie_resolver.dart';
import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import '../shared/provider_descriptors.dart';
import 'zai_fetch_strategy.dart';

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
      creditsHint: '',
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

    // 1. API token strategy (if ZAI_API_TOKEN is set)
    final api = ZaiAPIFetchStrategy();
    if (await api.isAvailable(context)) {
      strategies.add(api);
    }

    // 2. Cookie strategy (always available as fallback)
    strategies.add(CookieFetchStrategy(
      provider: UsageProvider.zai,
      apiDomain: 'api.z.ai',
    ));

    return strategies;
  }
}
