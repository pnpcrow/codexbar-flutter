import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6C5CE7);
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDAA5E);
  static const Color error = Color(0xFFE17055);
  static const Color info = Color(0xFF74B9FF);

  static Color progressColor(UsageProvider provider) {
    switch (provider) {
      case UsageProvider.claude:
        return const Color(0xFFD4A574);
      case UsageProvider.codex:
        return const Color(0xFF10A37F);
      case UsageProvider.gemini:
        return const Color(0xFF4285F4);
      case UsageProvider.cursor:
        return const Color(0xFF7C3AED);
      case UsageProvider.openai:
        return const Color(0xFF10A37F);
      default:
        return primary;
    }
  }
}

class AppSizes {
  static const double trayIconSize = 18.0;
  static const double popupWidth = 380.0;
  static const double popupMaxHeight = 600.0;
  static const double cardPadding = 16.0;
  static const double progressBarHeight = 8.0;
  static const double borderRadius = 12.0;
  static const double settingsSidebarWidth = 260.0;
  static const double settingsWindowWidth = 880.0;
  static const double settingsWindowHeight = 620.0;
}

// Forward declaration - will be defined in providers.dart
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
        return 'Droid';
      case UsageProvider.gemini:
        return 'Gemini';
      case UsageProvider.antigravity:
        return 'Antigravity';
      case UsageProvider.copilot:
        return 'Copilot';
      case UsageProvider.devin:
        return 'Devin';
      case UsageProvider.zai:
        return 'z.ai';
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
        return 'JetBrains AI';
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
        return 'OpenRouter';
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
        return 'CrossModel';
      case UsageProvider.clawrouter:
        return 'ClawRouter';
      case UsageProvider.sub2api:
        return 'sub2api';
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
      case UsageProvider.gemini:
        return 'gemini';
      case UsageProvider.cursor:
        return 'cursor';
      case UsageProvider.openai:
        return 'openai';
      default:
        return name;
    }
  }
}
