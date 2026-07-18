import 'dart:io';

import '../models/usage_provider.dart';

/// Token resolution result.
class TokenResolution {
  final String token;
  final TokenSource source;

  const TokenResolution({required this.token, required this.source});
}

enum TokenSource {
  environment,
  authFile,
  cli,
}

/// Resolves CLI tokens for providers.
/// Direct port of Swift ProviderTokenResolver.
class CLITokenResolver {
  static final CLITokenResolver _instance = CLITokenResolver._();
  factory CLITokenResolver() => _instance;
  CLITokenResolver._();

  /// Resolve token for a provider from environment variables or CLI.
  TokenResolution? resolve(UsageProvider provider, {Map<String, String>? env}) {
    env ??= Platform.environment;
    switch (provider) {
      case UsageProvider.openai:
        return _resolveEnv(env['OPENAI_API_KEY']);
      case UsageProvider.azureopenai:
        return _resolveEnv(env['AZURE_OPENAI_API_KEY']);
      case UsageProvider.claude:
        return _resolveEnv(env['ANTHROPIC_API_KEY']);
      case UsageProvider.copilot:
        return _resolveEnv(env['COPILOT_API_TOKEN']);
      case UsageProvider.deepseek:
        return _resolveEnv(env['DEEPSEEK_API_KEY']);
      case UsageProvider.moonshot:
        return _resolveEnv(env['MOONSHOT_API_KEY']);
      case UsageProvider.amp:
        return _resolveEnv(env['AMP_API_TOKEN']);
      case UsageProvider.zai:
        return _resolveEnv(env['ZAI_API_TOKEN']);
      case UsageProvider.synthetic:
        return _resolveEnv(env['SYNTHETIC_API_KEY']);
      case UsageProvider.openrouter:
        return _resolveEnv(env['OPENROUTER_API_TOKEN']);
      case UsageProvider.elevenlabs:
        return _resolveEnv(env['ELEVENLABS_API_KEY']);
      case UsageProvider.groq:
        return _resolveEnv(env['GROQ_API_KEY']);
      case UsageProvider.llmproxy:
        return _resolveEnv(env['LLMPROXY_API_KEY']);
      case UsageProvider.litellm:
        return _resolveEnv(env['LITELLM_API_KEY']);
      case UsageProvider.clawrouter:
        return _resolveEnv(env['CLAWROUTER_API_KEY']);
      case UsageProvider.crossmodel:
        return _resolveEnv(env['CROSSMODEL_API_TOKEN']);
      case UsageProvider.warp:
        return _resolveEnv(env['WARP_API_KEY']);
      case UsageProvider.doubao:
        return _resolveEnv(env['DOUBAO_API_KEY']);
      case UsageProvider.stepfun:
        return _resolveEnv(env['STEPFUN_TOKEN']);
      case UsageProvider.venice:
        return _resolveEnv(env['VENICE_API_KEY']);
      case UsageProvider.crof:
        return _resolveEnv(env['CROF_API_KEY']);
      case UsageProvider.poe:
        return _resolveEnv(env['POE_API_KEY']);
      case UsageProvider.bedrock:
        return _resolveEnv(env['AWS_ACCESS_KEY_ID']);
      case UsageProvider.kimi:
        return _resolveEnv(env['KIMI_AUTH_TOKEN'] ?? env['KIMI_API_KEY']);
      case UsageProvider.kimik2:
        return _resolveEnv(env['KIMI_K2_API_KEY']);
      case UsageProvider.minimax:
        return _resolveEnv(env['MINIMAX_API_TOKEN']);
      case UsageProvider.alibaba:
        return _resolveEnv(env['ALIBABA_API_TOKEN']);
      case UsageProvider.perplexity:
        return _resolveEnv(env['PERPLEXITY_SESSION_TOKEN']);
      case UsageProvider.deepgram:
        return _resolveEnv(env['DEEPGRAM_API_KEY']);
      default:
        return null;
    }
  }

  /// Check if a CLI binary is available in PATH.
  Future<bool> isCLIAvailable(UsageProvider provider) async {
    final binary = provider.cliName;
    try {
      final result = await Process.run('which', [binary]);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  /// Resolve CLI binary path.
  Future<String?> resolveCLIPath(UsageProvider provider) async {
    final binary = provider.cliName;
    try {
      final result = await Process.run('which', [binary]);
      if (result.exitCode == 0) {
        return (result.stdout as String).trim();
      }
    } catch (_) {}
    return null;
  }

  TokenResolution? _resolveEnv(String? token) {
    if (token == null || token.trim().isEmpty) return null;
    var cleaned = token.trim();
    // Remove surrounding quotes
    if ((cleaned.startsWith('"') && cleaned.endsWith('"')) ||
        (cleaned.startsWith("'") && cleaned.endsWith("'"))) {
      cleaned = cleaned.substring(1, cleaned.length - 1);
    }
    cleaned = cleaned.trim();
    if (cleaned.isEmpty) return null;
    return TokenResolution(token: cleaned, source: TokenSource.environment);
  }
}
