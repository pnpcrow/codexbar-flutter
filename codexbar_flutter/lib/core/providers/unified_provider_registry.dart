import 'dart:io';

import '../auth/browser_cookie_resolver.dart';
import '../debug/debug_logger.dart';
import '../models/fetch_kind.dart';
import '../models/fetch_result.dart';
import '../models/provider_branding.dart';
import '../models/provider_metadata.dart';
import '../models/usage_provider.dart';
import '../models/usage_snapshot.dart';
import 'fetch_strategy.dart';
import 'provider_descriptor.dart';
import 'shared/all_provider_endpoints.dart';
import 'shared/generic_api_strategy.dart';
import 'shared/provider_descriptors.dart';

/// Unified provider registry that properly maps all60 providers.
/// Based on original CodexBar implementation analysis.
class UnifiedProviderRegistry {
  /// Register all providers with correct strategies.
  static void registerAll(dynamic registry) {
    for (final provider in UsageProvider.values) {
      final descriptor = _createDescriptor(provider);
      if (descriptor != null) {
        registry.register(descriptor);
      }
    }
  }

  static ProviderDescriptor? _createDescriptor(UsageProvider provider) {
    final metadata = _createMetadata(provider);
    final branding = _createBranding(provider);
    final pipeline = _createPipeline(provider);

    return ProviderDescriptor(
      id: provider,
      metadata: metadata,
      branding: branding,
      pipeline: pipeline,
      cliName: provider.cliName,
    );
  }

  static ProviderMetadata _createMetadata(UsageProvider provider) {
    return ProviderMetadata(
      id: provider,
      displayName: provider.displayName,
      sessionLabel: 'Usage',
      weeklyLabel: 'Quota',
      supportsOpus: false,
      supportsCredits: false,
      creditsHint: '',
      toggleTitle: 'Show ${provider.displayName} usage',
      cliName: provider.cliName,
      defaultEnabled: false,
    );
  }

  static ProviderBranding _createBranding(UsageProvider provider) {
    return ProviderBranding(
      iconStyle: provider.name,
      iconResourceName: 'ProviderIcon-${provider.name}',
      colorValue: _getColor(provider),
    );
  }

  static int _getColor(UsageProvider provider) {
    switch (provider) {
      case UsageProvider.codex: return 0xFF10A37F;
      case UsageProvider.openai: return 0xFF0F8273;
      case UsageProvider.claude: return 0xFFCC7C5E;
      case UsageProvider.cursor: return 0xFF000000;
      case UsageProvider.gemini: return 0xFF4285F4;
      case UsageProvider.deepseek: return 0xFF4D6BFE;
      case UsageProvider.mistral: return 0xFFFF7F00;
      case UsageProvider.perplexity: return 0xFF1B7CED;
      case UsageProvider.mimo: return 0xFFFF6B35;
      case UsageProvider.minimax: return 0xFF00D4AA;
      case UsageProvider.zai: return 0xFFE85A6A;
      case UsageProvider.grok: return 0xFF1DA1F2;
      case UsageProvider.copilot: return 0xFF000000;
      case UsageProvider.windsurf: return 0xFF00D4AA;
      case UsageProvider.warp: return 0xFF00D4AA;
      case UsageProvider.ollama: return 0xFFFFFFFF;
      default: return 0xFF607D8B;
    }
  }

  static FetchPipeline _createPipeline(UsageProvider provider) {
    return FetchPipeline(
      resolveStrategies: (context) async {
        final strategies = <FetchStrategy>[];

        // 1. API token strategy (if env var is set)
        final apiStrategy = _createAPIStrategy(provider);
        if (apiStrategy != null && await apiStrategy.isAvailable(context)) {
          strategies.add(apiStrategy);
        }

        // 2. Cookie strategy (for providers that support it)
        if (_supportsCookies(provider)) {
          strategies.add(CookieFetchStrategy(
            provider: provider,
            apiDomain: _getApiDomain(provider),
          ));
        }

        return strategies;
      },
    );
  }

  static FetchStrategy? _createAPIStrategy(UsageProvider provider) {
    final envVar = ProviderEndpoints.getEnvVar(provider);
    if (envVar == null) return null;

    return ProviderAPIFetchStrategy(
      id: '${provider.name}.api',
      provider: provider,
    );
  }

  static bool _supportsCookies(UsageProvider provider) {
    switch (provider) {
      case UsageProvider.claude:
      case UsageProvider.cursor:
      case UsageProvider.copilot:
      case UsageProvider.mistral:
      case UsageProvider.grok:
      case UsageProvider.devin:
      case UsageProvider.factory:
      case UsageProvider.manus:
      case UsageProvider.augment:
      case UsageProvider.windsurf:
      case UsageProvider.kiro:
      case UsageProvider.commandcode:
      case UsageProvider.qoder:
      case UsageProvider.perplexity:
      case UsageProvider.mimo:
      case UsageProvider.minimax:
      case UsageProvider.openai:
        return true;
      default:
        return false;
    }
  }

  static String _getApiDomain(UsageProvider provider) {
    switch (provider) {
      case UsageProvider.claude: return 'claude.ai';
      case UsageProvider.cursor: return 'cursor.com';
      case UsageProvider.copilot: return 'github.com';
      case UsageProvider.mistral: return 'admin.mistral.ai';
      case UsageProvider.grok: return 'grok.com';
      case UsageProvider.devin: return 'devin.ai';
      case UsageProvider.factory: return 'factory.ai';
      case UsageProvider.manus: return 'manus.im';
      case UsageProvider.augment: return 'augmentcode.com';
      case UsageProvider.windsurf: return 'windsurf.com';
      case UsageProvider.kiro: return 'kiro.dev';
      case UsageProvider.commandcode: return 'commandcode.dev';
      case UsageProvider.qoder: return 'qoder.com';
      case UsageProvider.perplexity: return 'perplexity.ai';
      case UsageProvider.mimo: return 'xiaomimimo.com';
      case UsageProvider.minimax: return 'minimax.io';
      case UsageProvider.openai: return 'openai.com';
      default: return '${provider.name}.com';
    }
  }
}
