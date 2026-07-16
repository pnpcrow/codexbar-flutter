import 'package:flutter/foundation.dart';

import '../models/usage_provider.dart';
import 'provider_descriptor.dart';
import 'provider_fetch_pipeline.dart';

/// Bundles a provider's descriptor with its fetch pipeline, mirroring the
/// Swift `ProviderDescriptor` + registry lookup split.
@immutable
class ProviderRegistration {
  const ProviderRegistration({
    required this.descriptor,
    required this.pipeline,
  });

  final ProviderDescriptor descriptor;
  final ProviderFetchPipeline pipeline;
}

/// Central registry mapping every [UsageProvider] to its descriptor + pipeline.
///
/// Ported from `ProviderDescriptorRegistry` in `ProviderDescriptor.swift`.
/// Providers that are not yet implemented in the Flutter port are registered
/// with a placeholder descriptor and an empty pipeline (no strategies) so the
/// enum is total; they surface as "not yet available" in the UI. Implemented
/// providers override the placeholder in the constructor.
class ProviderDescriptorRegistry {
  ProviderDescriptorRegistry({Map<UsageProvider, ProviderRegistration>? overrides})
      : _registrations = {} {
    // Seed every known provider with a placeholder so the registry is total.
    for (final provider in UsageProvider.all) {
      _registrations[provider] = _placeholder(provider);
    }
    if (overrides != null) {
      for (final entry in overrides.entries) {
        _registrations[entry.key] = entry.value;
      }
    }
  }

  final Map<UsageProvider, ProviderRegistration> _registrations;

  /// Registration for [provider], never `null`.
  ProviderRegistration registrationFor(UsageProvider provider) =>
      _registrations[provider] ?? _placeholder(provider);

  ProviderDescriptor descriptorFor(UsageProvider provider) =>
      registrationFor(provider).descriptor;

  ProviderFetchPipeline pipelineFor(UsageProvider provider) =>
      registrationFor(provider).pipeline;

  /// All registrations that have at least one fetch strategy (i.e. are
  /// implemented in this port).
  List<ProviderRegistration> get implemented =>
      _registrations.values.where((r) => r.pipeline.strategies.isNotEmpty).toList();

  static ProviderRegistration _placeholder(UsageProvider provider) {
    return ProviderRegistration(
      descriptor: ProviderDescriptor(
        metadata: ProviderMetadata(
          id: provider,
          displayName: _displayName(provider),
          sessionLabel: 'Session',
          weeklyLabel: 'Weekly',
          defaultEnabled: false,
        ),
        branding: ProviderBranding(
          iconStyle: IconStyle.forProvider(provider),
          iconResourceName: 'ProviderIcon-${provider.name}',
        ),
      ),
      pipeline: const ProviderFetchPipeline([]),
    );
  }

  /// Best-effort human display name from the raw provider name.
  static String _displayName(UsageProvider provider) {
    final known = <UsageProvider, String>{
      UsageProvider.codex: 'Codex',
      UsageProvider.openai: 'OpenAI',
      UsageProvider.azureopenai: 'Azure OpenAI',
      UsageProvider.claude: 'Claude',
      UsageProvider.cursor: 'Cursor',
      UsageProvider.opencode: 'OpenCode',
      UsageProvider.opencodego: 'OpenCode Go',
      UsageProvider.alibaba: 'Alibaba',
      UsageProvider.alibabatokenplan: 'Alibaba Token Plan',
      UsageProvider.factory: 'Factory',
      UsageProvider.gemini: 'Gemini',
      UsageProvider.antigravity: 'Antigravity',
      UsageProvider.copilot: 'GitHub Copilot',
      UsageProvider.devin: 'Devin',
      UsageProvider.zai: 'Z.ai',
      UsageProvider.minimax: 'MiniMax',
      UsageProvider.manus: 'Manus',
      UsageProvider.kimi: 'Kimi',
      UsageProvider.kilo: 'Kilo',
      UsageProvider.kiro: 'Kiro',
      UsageProvider.vertexai: 'Vertex AI',
      UsageProvider.augment: 'Augment',
      UsageProvider.jetbrains: 'JetBrains',
      UsageProvider.kimik2: 'Kimi K2',
      UsageProvider.moonshot: 'Moonshot',
      UsageProvider.amp: 'Amp',
      UsageProvider.t3chat: 'T3 Chat',
      UsageProvider.ollama: 'Ollama',
      UsageProvider.synthetic: 'Synthetic',
      UsageProvider.warp: 'Warp',
      UsageProvider.openrouter: 'OpenRouter',
      UsageProvider.elevenlabs: 'ElevenLabs',
      UsageProvider.windsurf: 'Windsurf',
      UsageProvider.zed: 'Zed',
      UsageProvider.perplexity: 'Perplexity',
      UsageProvider.mimo: 'MiMo',
      UsageProvider.doubao: 'Doubao',
      UsageProvider.sakana: 'Sakana',
      UsageProvider.abacus: 'Abacus',
      UsageProvider.mistral: 'Mistral',
      UsageProvider.deepseek: 'DeepSeek',
      UsageProvider.codebuff: 'Codebuff',
      UsageProvider.crof: 'Crof',
      UsageProvider.venice: 'Venice',
      UsageProvider.commandcode: 'Command Code',
      UsageProvider.qoder: 'Qoder',
      UsageProvider.stepfun: 'StepFun',
      UsageProvider.bedrock: 'Bedrock',
      UsageProvider.grok: 'Grok',
      UsageProvider.groq: 'Groq',
      UsageProvider.llmproxy: 'LLM Proxy',
      UsageProvider.litellm: 'LiteLLM',
      UsageProvider.deepgram: 'Deepgram',
      UsageProvider.poe: 'Poe',
      UsageProvider.chutes: 'Chutes',
      UsageProvider.crossmodel: 'CrossModel',
      UsageProvider.clawrouter: 'ClawRouter',
      UsageProvider.sub2api: 'Sub2API',
      UsageProvider.wayfinder: 'Wayfinder',
      UsageProvider.zenmux: 'ZenMux',
    };
    return known[provider] ?? provider.name[0].toUpperCase() + provider.name.substring(1);
  }
}
