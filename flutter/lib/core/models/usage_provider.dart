import 'package:flutter/foundation.dart';

/// All provider identifiers supported by CodexBar.
///
/// Ported from `UsageProvider` in `Sources/CodexBarCore/Providers/Providers.swift`.
/// All 60 cases are declared so that future provider additions map 1:1 to the
/// upstream enum. Only a subset are actively implemented in the Flutter port
/// initially; see `docs/upstream/PORT_MAP.md`.
@immutable
class UsageProvider {
  const UsageProvider._(this.name);

  /// Wire/raw name, matching the Swift enum case raw value exactly.
  final String name;

  static const codex = UsageProvider._('codex');
  static const openai = UsageProvider._('openai');
  static const azureopenai = UsageProvider._('azureopenai');
  static const claude = UsageProvider._('claude');
  static const cursor = UsageProvider._('cursor');
  static const opencode = UsageProvider._('opencode');
  static const opencodego = UsageProvider._('opencodego');
  static const alibaba = UsageProvider._('alibaba');
  static const alibabatokenplan = UsageProvider._('alibabatokenplan');
  static const factory = UsageProvider._('factory');
  static const gemini = UsageProvider._('gemini');
  static const antigravity = UsageProvider._('antigravity');
  static const copilot = UsageProvider._('copilot');
  static const devin = UsageProvider._('devin');
  static const zai = UsageProvider._('zai');
  static const minimax = UsageProvider._('minimax');
  static const manus = UsageProvider._('manus');
  static const kimi = UsageProvider._('kimi');
  static const kilo = UsageProvider._('kilo');
  static const kiro = UsageProvider._('kiro');
  static const vertexai = UsageProvider._('vertexai');
  static const augment = UsageProvider._('augment');
  static const jetbrains = UsageProvider._('jetbrains');
  static const kimik2 = UsageProvider._('kimik2');
  static const moonshot = UsageProvider._('moonshot');
  static const amp = UsageProvider._('amp');
  static const t3chat = UsageProvider._('t3chat');
  static const ollama = UsageProvider._('ollama');
  static const synthetic = UsageProvider._('synthetic');
  static const warp = UsageProvider._('warp');
  static const openrouter = UsageProvider._('openrouter');
  static const elevenlabs = UsageProvider._('elevenlabs');
  static const windsurf = UsageProvider._('windsurf');
  static const zed = UsageProvider._('zed');
  static const perplexity = UsageProvider._('perplexity');
  static const mimo = UsageProvider._('mimo');
  static const doubao = UsageProvider._('doubao');
  static const sakana = UsageProvider._('sakana');
  static const abacus = UsageProvider._('abacus');
  static const mistral = UsageProvider._('mistral');
  static const deepseek = UsageProvider._('deepseek');
  static const codebuff = UsageProvider._('codebuff');
  static const crof = UsageProvider._('crof');
  static const venice = UsageProvider._('venice');
  static const commandcode = UsageProvider._('commandcode');
  static const qoder = UsageProvider._('qoder');
  static const stepfun = UsageProvider._('stepfun');
  static const bedrock = UsageProvider._('bedrock');
  static const grok = UsageProvider._('grok');
  static const groq = UsageProvider._('groq');
  static const llmproxy = UsageProvider._('llmproxy');
  static const litellm = UsageProvider._('litellm');
  static const deepgram = UsageProvider._('deepgram');
  static const poe = UsageProvider._('poe');
  static const chutes = UsageProvider._('chutes');
  static const crossmodel = UsageProvider._('crossmodel');
  static const clawrouter = UsageProvider._('clawrouter');
  static const sub2api = UsageProvider._('sub2api');
  static const wayfinder = UsageProvider._('wayfinder');
  static const zenmux = UsageProvider._('zenmux');

  /// All known providers, in upstream declaration order.
  static const List<UsageProvider> all = [
    codex, openai, azureopenai, claude, cursor, opencode, opencodego, alibaba,
    alibabatokenplan, factory, gemini, antigravity, copilot, devin, zai, minimax,
    manus, kimi, kilo, kiro, vertexai, augment, jetbrains, kimik2, moonshot, amp,
    t3chat, ollama, synthetic, warp, openrouter, elevenlabs, windsurf, zed,
    perplexity, mimo, doubao, sakana, abacus, mistral, deepseek, codebuff, crof,
    venice, commandcode, qoder, stepfun, bedrock, grok, groq, llmproxy, litellm,
    deepgram, poe, chutes, crossmodel, clawrouter, sub2api, wayfinder, zenmux,
  ];

  /// Lookup by raw name (case-insensitive). Returns `null` if unknown.
  static UsageProvider? fromString(String? value) {
    if (value == null) return null;
    final lower = value.toLowerCase();
    for (final p in all) {
      if (p.name == lower) return p;
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UsageProvider && other.name == name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => name;
}

/// Icon rendering style per provider. Mirrors `IconStyle` in `Providers.swift`,
/// including the trailing `combined` case that has no `UsageProvider` counterpart.
@immutable
class IconStyle {
  const IconStyle._(this.name);

  final String name;

  static const codex = IconStyle._('codex');
  static const openai = IconStyle._('openai');
  static const claude = IconStyle._('claude');
  static const zai = IconStyle._('zai');
  static const minimax = IconStyle._('minimax');
  static const manus = IconStyle._('manus');
  static const gemini = IconStyle._('gemini');
  static const antigravity = IconStyle._('antigravity');
  static const cursor = IconStyle._('cursor');
  static const opencode = IconStyle._('opencode');
  static const opencodego = IconStyle._('opencodego');
  static const alibaba = IconStyle._('alibaba');
  static const factory = IconStyle._('factory');
  static const copilot = IconStyle._('copilot');
  static const devin = IconStyle._('devin');
  static const kimi = IconStyle._('kimi');
  static const kimik2 = IconStyle._('kimik2');
  static const kilo = IconStyle._('kilo');
  static const kiro = IconStyle._('kiro');
  static const vertexai = IconStyle._('vertexai');
  static const augment = IconStyle._('augment');
  static const jetbrains = IconStyle._('jetbrains');
  static const moonshot = IconStyle._('moonshot');
  static const amp = IconStyle._('amp');
  static const t3chat = IconStyle._('t3chat');
  static const ollama = IconStyle._('ollama');
  static const synthetic = IconStyle._('synthetic');
  static const warp = IconStyle._('warp');
  static const openrouter = IconStyle._('openrouter');
  static const elevenlabs = IconStyle._('elevenlabs');
  static const windsurf = IconStyle._('windsurf');
  static const zed = IconStyle._('zed');
  static const perplexity = IconStyle._('perplexity');
  static const mimo = IconStyle._('mimo');
  static const doubao = IconStyle._('doubao');
  static const sakana = IconStyle._('sakana');
  static const abacus = IconStyle._('abacus');
  static const mistral = IconStyle._('mistral');
  static const deepseek = IconStyle._('deepseek');
  static const codebuff = IconStyle._('codebuff');
  static const crof = IconStyle._('crof');
  static const venice = IconStyle._('venice');
  static const commandcode = IconStyle._('commandcode');
  static const qoder = IconStyle._('qoder');
  static const stepfun = IconStyle._('stepfun');
  static const bedrock = IconStyle._('bedrock');
  static const grok = IconStyle._('grok');
  static const groq = IconStyle._('groq');
  static const llmproxy = IconStyle._('llmproxy');
  static const litellm = IconStyle._('litellm');
  static const deepgram = IconStyle._('deepgram');
  static const poe = IconStyle._('poe');
  static const chutes = IconStyle._('chutes');
  static const crossmodel = IconStyle._('crossmodel');
  static const clawrouter = IconStyle._('clawrouter');
  static const sub2api = IconStyle._('sub2api');
  static const wayfinder = IconStyle._('wayfinder');
  static const zenmux = IconStyle._('zenmux');
  static const combined = IconStyle._('combined');

  /// The icon style for a given provider, defaulting to the matching name.
  factory IconStyle.forProvider(UsageProvider provider) =>
      IconStyle._(provider.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is IconStyle && other.name == name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => name;
}

/// Severity of a provider status indicator, surfaced on the menu bar icon.
///
/// Ported from `ProviderStatusIndicator` in `UsageStoreSupport.swift`.
enum ProviderStatusIndicator {
  none,
  minor,
  major,
  critical,
  maintenance,
  unknown;

  bool get hasIssue => this != ProviderStatusIndicator.none;

  /// Maps a statuspage.io component status string to an indicator.
  static ProviderStatusIndicator fromStatusPageStatus(String status) {
    return switch (status) {
      'operational' => ProviderStatusIndicator.none,
      'degraded_performance' => ProviderStatusIndicator.minor,
      'partial_outage' => ProviderStatusIndicator.major,
      'major_outage' || 'full_outage' => ProviderStatusIndicator.critical,
      'under_maintenance' => ProviderStatusIndicator.maintenance,
      _ => ProviderStatusIndicator.unknown,
    };
  }
}

/// A provider status summary fetched from a status page.
///
/// Ported from `ProviderStatus` in `UsageStoreSupport.swift`.
@immutable
class ProviderStatus {
  const ProviderStatus({
    this.indicator = ProviderStatusIndicator.none,
    this.description,
    this.updatedAt,
  });

  final ProviderStatusIndicator indicator;
  final String? description;
  final DateTime? updatedAt;
}
