/// All supported AI coding providers.
/// Direct port of Swift UsageProvider enum from CodexBarCore.
enum UsageProvider {
  codex,
  openai,
  azureopenai,
  claude,
  cursor,
  opencode,
  opencodego,
  alibaba,
  alibabatokenplan,
  factory,
  gemini,
  antigravity,
  copilot,
  devin,
  zai,
  minimax,
  manus,
  kimi,
  kilo,
  kiro,
  vertexai,
  augment,
  jetbrains,
  kimik2,
  moonshot,
  amp,
  t3chat,
  ollama,
  synthetic,
  warp,
  openrouter,
  elevenlabs,
  windsurf,
  zed,
  perplexity,
  mimo,
  doubao,
  sakana,
  abacus,
  mistral,
  deepseek,
  codebuff,
  crof,
  venice,
  commandcode,
  qoder,
  stepfun,
  bedrock,
  grok,
  groq,
  llmproxy,
  litellm,
  deepgram,
  poe,
  chutes,
  crossmodel,
  clawrouter,
  sub2api,
  wayfinder,
  zenmux;

  String get displayName {
    switch (this) {
      case UsageProvider.codex:
        return 'Codex';
      case UsageProvider.openai:
        return 'OpenAI';
      case UsageProvider.azureopenai:
        return 'Azure OpenAI';
      case UsageProvider.claude:
        return 'Claude';
      case UsageProvider.cursor:
        return 'Cursor';
      case UsageProvider.opencode:
        return 'OpenCode';
      case UsageProvider.opencodego:
        return 'OpenCode Go';
      case UsageProvider.alibaba:
        return 'Alibaba';
      case UsageProvider.alibabatokenplan:
        return 'Alibaba Token Plan';
      case UsageProvider.factory:
        return 'Factory';
      case UsageProvider.gemini:
        return 'Gemini';
      case UsageProvider.antigravity:
        return 'Antigravity';
      case UsageProvider.copilot:
        return 'Copilot';
      case UsageProvider.devin:
        return 'Devin';
      case UsageProvider.zai:
        return 'Zai';
      case UsageProvider.minimax:
        return 'MiniMax';
      case UsageProvider.manus:
        return 'Manus';
      case UsageProvider.kimi:
        return 'Kimi';
      case UsageProvider.kilo:
        return 'Kilo';
      case UsageProvider.kiro:
        return 'Kiro';
      case UsageProvider.vertexai:
        return 'Vertex AI';
      case UsageProvider.augment:
        return 'Augment';
      case UsageProvider.jetbrains:
        return 'JetBrains';
      case UsageProvider.kimik2:
        return 'Kimi K2';
      case UsageProvider.moonshot:
        return 'Moonshot';
      case UsageProvider.amp:
        return 'Amp';
      case UsageProvider.t3chat:
        return 'T3 Chat';
      case UsageProvider.ollama:
        return 'Ollama';
      case UsageProvider.synthetic:
        return 'Synthetic';
      case UsageProvider.warp:
        return 'Warp';
      case UsageProvider.openrouter:
        return 'Open Router';
      case UsageProvider.elevenlabs:
        return 'ElevenLabs';
      case UsageProvider.windsurf:
        return 'Windsurf';
      case UsageProvider.zed:
        return 'Zed';
      case UsageProvider.perplexity:
        return 'Perplexity';
      case UsageProvider.mimo:
        return 'MiMo';
      case UsageProvider.doubao:
        return 'Doubao';
      case UsageProvider.sakana:
        return 'Sakana';
      case UsageProvider.abacus:
        return 'Abacus';
      case UsageProvider.mistral:
        return 'Mistral';
      case UsageProvider.deepseek:
        return 'DeepSeek';
      case UsageProvider.codebuff:
        return 'Codebuff';
      case UsageProvider.crof:
        return 'Crof';
      case UsageProvider.venice:
        return 'Venice';
      case UsageProvider.commandcode:
        return 'Command Code';
      case UsageProvider.qoder:
        return 'Qoder';
      case UsageProvider.stepfun:
        return 'StepFun';
      case UsageProvider.bedrock:
        return 'Bedrock';
      case UsageProvider.grok:
        return 'Grok';
      case UsageProvider.groq:
        return 'Groq';
      case UsageProvider.llmproxy:
        return 'LLM Proxy';
      case UsageProvider.litellm:
        return 'LiteLLM';
      case UsageProvider.deepgram:
        return 'Deepgram';
      case UsageProvider.poe:
        return 'Poe';
      case UsageProvider.chutes:
        return 'Chutes';
      case UsageProvider.crossmodel:
        return 'Cross Model';
      case UsageProvider.clawrouter:
        return 'Claw Router';
      case UsageProvider.sub2api:
        return 'Sub2API';
      case UsageProvider.wayfinder:
        return 'Wayfinder';
      case UsageProvider.zenmux:
        return 'ZenMux';
    }
  }

  String get cliName {
    switch (this) {
      case UsageProvider.codex:
        return 'codex';
      case UsageProvider.claude:
        return 'claude';
      case UsageProvider.cursor:
        return 'cursor';
      case UsageProvider.opencode:
        return 'opencode';
      case UsageProvider.opencodego:
        return 'opencodego';
      case UsageProvider.gemini:
        return 'gemini';
      case UsageProvider.antigravity:
        return 'antigravity';
      case UsageProvider.mimo:
        return 'mimo';
      case UsageProvider.kimik2:
        return 'kimik2';
      case UsageProvider.ollama:
        return 'ollama';
      case UsageProvider.synthetic:
        return 'synthetic';
      default:
        return name;
    }
  }
}
