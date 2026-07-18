import '../../models/usage_provider.dart';

/// Provider authentication type based on original CodexBar analysis.
enum ProviderAuthType {
  /// Web only - uses browser cookies for web API
  webOnly,

  /// API only - requires API key/token
  apiOnly,

  /// Both web and API - tries web first, falls back to API
  webAndApi,

  /// CLI only - uses command line binary
  cliOnly,

  /// No auth needed (local services)
  none,
}

/// Provider auth type mapping based on original CodexBar source analysis.
class ProviderAuthTypeMapper {
  static ProviderAuthType getAuthType(UsageProvider provider) {
    switch (provider) {
      // Web only (cookies from browser)
      case UsageProvider.abacus:
      case UsageProvider.antigravity:
      case UsageProvider.augment:
      case UsageProvider.codex:
      case UsageProvider.commandcode:
      case UsageProvider.cursor:
      case UsageProvider.devin:
      case UsageProvider.grok:
      case UsageProvider.manus:
      case UsageProvider.mimo:
      case UsageProvider.mistral:
      case UsageProvider.opencode:
      case UsageProvider.opencodego:
      case UsageProvider.perplexity:
      case UsageProvider.qoder:
      case UsageProvider.sakana:
      case UsageProvider.stepfun:
      case UsageProvider.t3chat:
      case UsageProvider.windsurf:
        return ProviderAuthType.webOnly;

      // API only (requires API key)
      case UsageProvider.bedrock:
      case UsageProvider.clawrouter:
      case UsageProvider.crossmodel:
      case UsageProvider.gemini:
      case UsageProvider.litellm:
      case UsageProvider.openai:
      case UsageProvider.openrouter:
      case UsageProvider.sub2api:
      case UsageProvider.synthetic:
      case UsageProvider.wayfinder:
      case UsageProvider.zai:
      case UsageProvider.zenmux:
        return ProviderAuthType.apiOnly;

      // Both web and API
      case UsageProvider.alibaba:
      case UsageProvider.amp:
      case UsageProvider.azureopenai:
      case UsageProvider.chutes:
      case UsageProvider.claude:
      case UsageProvider.codebuff:
      case UsageProvider.copilot:
      case UsageProvider.crof:
      case UsageProvider.deepseek:
      case UsageProvider.deepgram:
      case UsageProvider.doubao:
      case UsageProvider.elevenlabs:
      case UsageProvider.factory:
      case UsageProvider.groq:
      case UsageProvider.kilo:
      case UsageProvider.kimi:
      case UsageProvider.kimik2:
      case UsageProvider.kiro:
      case UsageProvider.llmproxy:
      case UsageProvider.minimax:
      case UsageProvider.moonshot:
      case UsageProvider.ollama:
      case UsageProvider.poe:
      case UsageProvider.venice:
      case UsageProvider.warp:
        return ProviderAuthType.webAndApi;

      // CLI only
      case UsageProvider.jetbrains:
      case UsageProvider.vertexai:
      case UsageProvider.zed:
        return ProviderAuthType.cliOnly;

      default:
        return ProviderAuthType.none;
    }
  }

  /// Get the web API domain for a provider (what the browser accesses).
  static String? getWebDomain(UsageProvider provider) {
    switch (provider) {
      case UsageProvider.claude: return 'claude.ai';
      case UsageProvider.cursor: return 'cursor.com';
      case UsageProvider.copilot: return 'github.com';
      case UsageProvider.mistral: return 'admin.mistral.ai';
      case UsageProvider.grok: return 'grok.com';
      case UsageProvider.devin: return 'app.devin.ai';
      case UsageProvider.factory: return 'factory.ai';
      case UsageProvider.manus: return 'manus.im';
      case UsageProvider.augment: return 'augmentcode.com';
      case UsageProvider.windsurf: return 'windsurf.com';
      case UsageProvider.kiro: return 'kiro.dev';
      case UsageProvider.commandcode: return 'commandcode.ai';
      case UsageProvider.qoder: return 'qoder.com';
      case UsageProvider.perplexity: return 'www.perplexity.ai';
      case UsageProvider.mimo: return 'platform.xiaomimimo.com';
      case UsageProvider.minimax: return 'platform.minimax.io';
      case UsageProvider.openai: return 'chatgpt.com';
      case UsageProvider.codex: return 'chatgpt.com';
      case UsageProvider.gemini: return 'gemini.google.com';
      case UsageProvider.ollama: return 'ollama.com';
      case UsageProvider.kimi: return 'kimi.com';
      case UsageProvider.moonshot: return 'platform.moonshot.cn';
      case UsageProvider.alibaba: return 'bailian.console.aliyun.com';
      case UsageProvider.deepseek: return 'chat.deepseek.com';
      case UsageProvider.doubao: return 'www.doubao.com';
      case UsageProvider.poe: return 'poe.com';
      case UsageProvider.t3chat: return 't3.chat';
      case UsageProvider.sakana: return 'console.sakana.ai';
      case UsageProvider.abacus: return 'apps.abacus.ai';
      case UsageProvider.antigravity: return 'antigravity.com';
      case UsageProvider.warp: return 'app.warp.dev';
      case UsageProvider.venice: return 'venice.ai';
      case UsageProvider.amp: return 'ampcode.com';
      default: return null;
    }
  }

  /// Get the API domain for a provider (developer API).
  static String? getApiDomain(UsageProvider provider) {
    switch (provider) {
      case UsageProvider.zai: return 'api.z.ai';
      case UsageProvider.openai: return 'api.openai.com';
      case UsageProvider.deepseek: return 'api.deepseek.com';
      case UsageProvider.moonshot: return 'api.moonshot.cn';
      case UsageProvider.groq: return 'api.groq.com';
      case UsageProvider.openrouter: return 'openrouter.ai';
      case UsageProvider.elevenlabs: return 'api.elevenlabs.io';
      case UsageProvider.venice: return 'api.venice.ai';
      case UsageProvider.warp: return 'app.warp.dev';
      case UsageProvider.minimax: return 'api.minimax.io';
      case UsageProvider.alibaba: return 'dashscope.aliyuncs.com';
      case UsageProvider.poe: return 'api.poe.com';
      case UsageProvider.kimi: return 'api.moonshot.cn';
      case UsageProvider.kimik2: return 'kimi-k2.ai';
      case UsageProvider.deepgram: return 'api.deepgram.com';
      case UsageProvider.codebuff: return 'api.codebuff.com';
      case UsageProvider.kilo: return 'api.kilo.ai';
      case UsageProvider.crof: return 'crof.ai';
      default: return null;
    }
  }

  /// Get the web API endpoints for a provider (what the browser uses).
  static List<String> getWebEndpoints(UsageProvider provider) {
    switch (provider) {
      case UsageProvider.claude:
        return [
          'https://claude.ai/api/organizations',
        ];
      case UsageProvider.mimo:
        return [
          'https://platform.xiaomimimo.com/api/v1/balance',
          'https://platform.xiaomimimo.com/api/v1/tokenPlan/detail',
          'https://platform.xiaomimimo.com/api/v1/tokenPlan/usage',
        ];
      case UsageProvider.minimax:
        return [
          'https://platform.minimax.io/v1/token_plan/remains',
          'https://platform.minimax.io/user-center/payment/coding-plan?cycle_type=3',
        ];
      case UsageProvider.grok:
        return [
          'https://grok.com/grok_api_v2.GrokBuildBilling/GetGrokCreditsConfig',
        ];
      case UsageProvider.mistral:
        return [
          'https://admin.mistral.ai/organization/usage',
          'https://console.mistral.ai/api-ui/trpc/billing.vibeUsage?batch=1&input=%7B%220%22%3A%7B%22json%22%3Anull%2C%22meta%22%3A%7B%22values%22%3A%5B%22undefined%22%5D%2C%22v%22%3A1%7D%7D%7D',
        ];
      case UsageProvider.perplexity:
        return [
          'https://www.perplexity.ai/rest/billing/credits?version=2.18&source=default',
        ];
      case UsageProvider.cursor:
        return [
          'https://cursor.com/api/usage',
        ];
      case UsageProvider.windsurf:
        return [
          'https://windsurf.com/_backend/exa.seat_management_pb.SeatManagementService/GetPlanStatus',
        ];
      case UsageProvider.qoder:
        return [
          'https://qoder.com/api/v2/me/usages/big_model_credits',
        ];
      case UsageProvider.t3chat:
        return [
          'https://t3.chat/api/trpc/getCustomerData',
        ];
      case UsageProvider.kimi:
        return [
          'https://www.kimi.com/apiv2/kimi.gateway.billing.v1.BillingService/GetUsages',
        ];
      case UsageProvider.poe:
        return [
          'https://api.poe.com/usage/current_balance',
        ];
      case UsageProvider.warp:
        return [
          'https://app.warp.dev/graphql/v2?op=GetRequestLimitInfo',
        ];
      default:
        return [];
    }
  }
}
