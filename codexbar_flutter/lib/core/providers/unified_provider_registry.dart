import 'dart:io';

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
      // Skip providers with dedicated descriptors (already registered)
      if (_hasDedicatedDescriptor(provider)) continue;

      final descriptor = _createDescriptor(provider);
      if (descriptor != null) {
        registry.register(descriptor);
      }
    }
  }

  /// Check if a provider has a dedicated descriptor registered elsewhere.
  static bool _hasDedicatedDescriptor(UsageProvider provider) {
    switch (provider) {
      case UsageProvider.codex:
      case UsageProvider.claude:
      case UsageProvider.openai:
      case UsageProvider.mimo:
      case UsageProvider.minimax:
      case UsageProvider.zai:
      case UsageProvider.deepseek:
      case UsageProvider.moonshot:
      case UsageProvider.amp:
      case UsageProvider.copilot:
      case UsageProvider.cursor:
      case UsageProvider.mistral:
      case UsageProvider.grok:
      case UsageProvider.perplexity:
      case UsageProvider.windsurf:
      case UsageProvider.kiro:
      case UsageProvider.warp:
      case UsageProvider.openrouter:
      case UsageProvider.elevenlabs:
      case UsageProvider.groq:
      case UsageProvider.llmproxy:
      case UsageProvider.litellm:
      case UsageProvider.clawrouter:
      case UsageProvider.crossmodel:
      case UsageProvider.doubao:
      case UsageProvider.stepfun:
      case UsageProvider.venice:
      case UsageProvider.crof:
      case UsageProvider.poe:
      case UsageProvider.kimi:
      case UsageProvider.kimik2:
      case UsageProvider.alibaba:
      case UsageProvider.perplexity:
      case UsageProvider.deepgram:
      case UsageProvider.synthetic:
      case UsageProvider.codebuff:
      case UsageProvider.kilo:
      case UsageProvider.devin:
      case UsageProvider.factory:
      case UsageProvider.manus:
      case UsageProvider.augment:
      case UsageProvider.commandcode:
      case UsageProvider.qoder:
        return true; // Has dedicated descriptor
      default:
        return false; // Use generic
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
      case UsageProvider.gemini: return 0xFF4285F4;
      case UsageProvider.ollama: return 0xFFFFFFFF;
      case UsageProvider.vertexai: return 0xFF4285F4;
      case UsageProvider.jetbrains: return 0xFF000000;
      case UsageProvider.antigravity: return 0xFF6C5CE7;
      case UsageProvider.bedrock: return 0xFFFF9900;
      case UsageProvider.t3chat: return 0xFF6C5CE7;
      case UsageProvider.zed: return 0xFF000000;
      case UsageProvider.sakana: return 0xFF2ECC71;
      case UsageProvider.abacus: return 0xFFE74C3C;
      case UsageProvider.chutes: return 0xFF9B59B6;
      case UsageProvider.sub2api: return 0xFF3498DB;
      case UsageProvider.wayfinder: return 0xFFF39C12;
      case UsageProvider.zenmux: return 0xFF1ABC9C;
      case UsageProvider.azureopenai: return 0xFF0078D4;
      case UsageProvider.opencode: return 0xFF2ECC71;
      case UsageProvider.opencodego: return 0xFF00ADD8;
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
      case UsageProvider.gemini:
      case UsageProvider.antigravity:
      case UsageProvider.jetbrains:
      case UsageProvider.t3chat:
      case UsageProvider.zed:
      case UsageProvider.sakana:
      case UsageProvider.abacus:
      case UsageProvider.chutes:
      case UsageProvider.sub2api:
      case UsageProvider.wayfinder:
      case UsageProvider.zenmux:
      case UsageProvider.bedrock:
      case UsageProvider.vertexai:
      case UsageProvider.azureopenai:
      case UsageProvider.opencode:
      case UsageProvider.opencodego:
        return false;
      default:
        return true;
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
      case UsageProvider.ollama: return 'ollama.com';
      default: return '${provider.name}.com';
    }
  }
}
