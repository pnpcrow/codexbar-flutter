import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/usage_provider.dart';
import '../core/providers/provider_descriptor.dart';
import '../core/providers/provider_descriptor_registry.dart';
import '../core/providers/provider_fetch_pipeline.dart';
import '../core/providers/implementations/anthropic_fetch_strategy.dart';
import '../core/providers/implementations/deepseek_fetch_strategy.dart';
import '../core/providers/implementations/openai_fetch_strategy.dart';
import '../core/providers/implementations/openrouter_fetch_strategy.dart';

/// Shared, lazily-built registry of all provider registrations. Built once and
/// reused by the usage store, settings panes, and tray popup so they agree on
/// which providers exist and are implemented.
final providerRegistryProvider = Provider<ProviderDescriptorRegistry>((ref) {
  return ProviderDescriptorRegistry(overrides: defaultProviderOverrides());
});

/// Builds the registrations for the four initially-implemented API-key
/// providers, overriding the placeholder descriptors with real metadata and
/// pipelines.
///
/// Add new providers here; the registry + pipeline architecture handles the
/// rest. See `docs/upstream/PORT_MAP.md` for the porting status of all 60.
Map<UsageProvider, ProviderRegistration> defaultProviderOverrides() {
  return {
    UsageProvider.openai: ProviderRegistration(
      descriptor: ProviderDescriptor(
        metadata: ProviderMetadata(
          id: UsageProvider.openai,
          displayName: 'OpenAI',
          sessionLabel: 'Session',
          weeklyLabel: 'Weekly',
          supportsCredits: true,
          defaultEnabled: false,
          dashboardURL: 'https://platform.openai.com/usage',
          statusPageURL: 'https://status.openai.com/',
        ),
        branding: ProviderBranding(
          iconStyle: IconStyle.openai,
          iconResourceName: 'ProviderIcon-openai',
          color: ProviderColor.from255(0, 0, 0),
        ),
      ),
      pipeline: ProviderFetchPipeline([OpenAIFetchStrategy()]),
    ),
    UsageProvider.claude: ProviderRegistration(
      descriptor: ProviderDescriptor(
        metadata: ProviderMetadata(
          id: UsageProvider.claude,
          displayName: 'Claude',
          sessionLabel: 'Session',
          weeklyLabel: 'Weekly',
          defaultEnabled: false,
          dashboardURL: 'https://console.anthropic.com/settings/usage',
          statusPageURL: 'https://status.anthropic.com/',
        ),
        branding: ProviderBranding(
          iconStyle: IconStyle.claude,
          iconResourceName: 'ProviderIcon-claude',
          color: ProviderColor.from255(217, 119, 87),
        ),
      ),
      pipeline: ProviderFetchPipeline([AnthropicFetchStrategy()]),
    ),
    UsageProvider.openrouter: ProviderRegistration(
      descriptor: ProviderDescriptor(
        metadata: ProviderMetadata(
          id: UsageProvider.openrouter,
          displayName: 'OpenRouter',
          sessionLabel: 'Session',
          weeklyLabel: 'Weekly',
          supportsCredits: true,
          defaultEnabled: false,
          dashboardURL: 'https://openrouter.ai/credits',
        ),
        branding: ProviderBranding(
          iconStyle: IconStyle.openrouter,
          iconResourceName: 'ProviderIcon-openrouter',
          color: ProviderColor.from255(100, 100, 255),
        ),
      ),
      pipeline: ProviderFetchPipeline([OpenRouterFetchStrategy()]),
    ),
    UsageProvider.deepseek: ProviderRegistration(
      descriptor: ProviderDescriptor(
        metadata: ProviderMetadata(
          id: UsageProvider.deepseek,
          displayName: 'DeepSeek',
          sessionLabel: 'Session',
          weeklyLabel: 'Weekly',
          defaultEnabled: false,
          dashboardURL: 'https://platform.deepseek.com/usage',
        ),
        branding: ProviderBranding(
          iconStyle: IconStyle.deepseek,
          iconResourceName: 'ProviderIcon-deepseek',
          color: ProviderColor.from255(77, 109, 255),
        ),
      ),
      pipeline: ProviderFetchPipeline([DeepSeekFetchStrategy()]),
    ),
  };
}
