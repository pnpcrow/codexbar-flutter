import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../debug/debug_logger.dart';
import '../../models/fetch_kind.dart';
import '../../models/fetch_result.dart';
import '../../models/provider_identity.dart';
import '../../models/rate_window.dart';
import '../../models/usage_provider.dart';
import '../../models/usage_snapshot.dart';
import '../fetch_strategy.dart';
import 'generic_api_strategy.dart';

/// Comprehensive provider endpoint mapping based on original CodexBar.
/// Each provider has its actual API endpoint and response parser.
class ProviderEndpoints {
  /// Get the API endpoint URL for a provider.
  static String? getEndpoint(UsageProvider provider) {
    switch (provider) {
      case UsageProvider.deepseek:
        return 'https://api.deepseek.com/user/balance';
      case UsageProvider.venice:
        return 'https://api.venice.ai/api/v1/billing/balance';
      case UsageProvider.kilo:
        return 'https://api.kilo.ai/api/profile';
      case UsageProvider.kimik2:
        return 'https://kimi-k2.ai/api/user/credits';
      case UsageProvider.abacus:
        return 'https://apps.abacus.ai/api/_getOrganizationComputePoints';
      case UsageProvider.crof:
        return 'https://crof.ai/usage_api/';
      case UsageProvider.manus:
        return 'https://api.manus.im/user.v1.UserService/GetAvailableCredits';
      case UsageProvider.poe:
        return 'https://api.poe.com/usage/current_balance';
      case UsageProvider.warp:
        return 'https://app.warp.dev/graphql/v2?op=GetRequestLimitInfo';
      case UsageProvider.openrouter:
        return 'https://openrouter.ai/api/v1/credits';
      case UsageProvider.groq:
        return 'https://api.groq.com/openai/v1/organization/rate_limits';
      case UsageProvider.elevenlabs:
        return 'https://api.elevenlabs.io/v1/user/subscription';
      case UsageProvider.llmproxy:
        return 'https://api.llmproxy.com/v1/usage';
      case UsageProvider.litellm:
        return 'https://api.litellm.com/v1/usage';
      case UsageProvider.clawrouter:
        return 'https://api.clawrouter.com/v1/usage';
      case UsageProvider.crossmodel:
        return 'https://api.crossmodel.ai/v1/usage';
      case UsageProvider.codebuff:
        return 'https://api.codebuff.com/v1/usage';
      case UsageProvider.deepgram:
        return 'https://api.deepgram.com/v1/projects';
      case UsageProvider.stepfun:
        return 'https://platform.stepfun.com/api/step.openapi.devcenter.Dashboard/GetStepPlanStatus';
      case UsageProvider.doubao:
        return 'https://open.volcengineapi.com/?Action=GetCodingPlanUsage&Version=2024-01-01';
      case UsageProvider.amp:
        return 'https://ampcode.com/api/internal?userDisplayBalanceInfo';
      case UsageProvider.qoder:
        return 'https://qoder.com/api/v2/me/usages/big_model_credits';
      case UsageProvider.kimi:
        return 'https://www.kimi.com/apiv2/kimi.gateway.billing.v1.BillingService/GetUsages';
      case UsageProvider.moonshot:
        return 'https://api.moonshot.cn/v1/users/me/balance';
      case UsageProvider.alibaba:
        return 'https://dashscope.aliyuncs.com/api/v1/user';
      case UsageProvider.t3chat:
        return 'https://t3.chat/api/trpc/getCustomerData';
      case UsageProvider.sakana:
        return 'https://console.sakana.ai/billing';
      case UsageProvider.zenmux:
        return 'https://zenmux.ai/api/v1/management';
      default:
        return null;
    }
  }

  /// Get the env var name for a provider's API key.
  static String? getEnvVar(UsageProvider provider) {
    switch (provider) {
      case UsageProvider.openai:
        return 'OPENAI_API_KEY';
      case UsageProvider.azureopenai:
        return 'AZURE_OPENAI_API_KEY';
      case UsageProvider.claude:
        return 'ANTHROPIC_API_KEY';
      case UsageProvider.copilot:
        return 'COPILOT_API_TOKEN';
      case UsageProvider.deepseek:
        return 'DEEPSEEK_API_KEY';
      case UsageProvider.moonshot:
        return 'MOONSHOT_API_KEY';
      case UsageProvider.amp:
        return 'AMP_API_TOKEN';
      case UsageProvider.zai:
        return 'Z_AI_API_KEY';
      case UsageProvider.synthetic:
        return 'SYNTHETIC_API_KEY';
      case UsageProvider.openrouter:
        return 'OPENROUTER_API_KEY';
      case UsageProvider.elevenlabs:
        return 'ELEVENLABS_API_KEY';
      case UsageProvider.groq:
        return 'GROQ_API_KEY';
      case UsageProvider.llmproxy:
        return 'LLMPROXY_API_KEY';
      case UsageProvider.litellm:
        return 'LITELLM_API_KEY';
      case UsageProvider.clawrouter:
        return 'CLAWROUTER_API_KEY';
      case UsageProvider.crossmodel:
        return 'CROSSMODEL_API_KEY';
      case UsageProvider.warp:
        return 'WARP_API_KEY';
      case UsageProvider.doubao:
        return 'DOUBAO_API_KEY';
      case UsageProvider.stepfun:
        return 'STEPFUN_TOKEN';
      case UsageProvider.venice:
        return 'VENICE_API_KEY';
      case UsageProvider.crof:
        return 'CROF_API_KEY';
      case UsageProvider.poe:
        return 'POE_API_KEY';
      case UsageProvider.kimi:
        return 'KIMI_AUTH_TOKEN';
      case UsageProvider.kimik2:
        return 'KIMI_K2_API_KEY';
      case UsageProvider.minimax:
        return 'MINIMAX_API_TOKEN';
      case UsageProvider.alibaba:
        return 'ALIBABA_API_TOKEN';
      case UsageProvider.perplexity:
        return 'PERPLEXITY_SESSION_TOKEN';
      case UsageProvider.deepgram:
        return 'DEEPGRAM_API_KEY';
      case UsageProvider.codebuff:
        return 'CODEBUFF_API_KEY';
      case UsageProvider.kilo:
        return 'KILO_API_KEY';
      case UsageProvider.devin:
        return 'DEVIN_BEARER_TOKEN';
      case UsageProvider.qoder:
        return 'QODER_API_KEY';
      default:
        return null;
    }
  }

  /// Get the auth header format for a provider.
  static String getAuthHeader(UsageProvider provider, String token) {
    switch (provider) {
      case UsageProvider.deepgram:
        return 'Token $token';
      case UsageProvider.copilot:
        return 'Bearer $token';
      default:
        return 'Bearer $token';
    }
  }

  /// Parse the API response for a provider.
  static UsageSnapshot parseResponse(UsageProvider provider, Map<String, dynamic> json) {
    switch (provider) {
      case UsageProvider.deepseek:
        return _parseDeepSeek(json);
      case UsageProvider.venice:
        return _parseVenice(json);
      case UsageProvider.openrouter:
        return _parseOpenRouter(json);
      case UsageProvider.groq:
        return _parseGroq(json);
      case UsageProvider.elevenlabs:
        return _parseElevenLabs(json);
      case UsageProvider.moonshot:
        return _parseMoonshot(json);
      case UsageProvider.kimi:
        return _parseKimi(json);
      case UsageProvider.kimik2:
        return _parseKimiK2(json);
      case UsageProvider.poe:
        return _parsePoe(json);
      case UsageProvider.warp:
        return _parseWarp(json);
      case UsageProvider.manus:
        return _parseManus(json);
      case UsageProvider.kilo:
        return _parseKilo(json);
      case UsageProvider.abacus:
        return _parseAbacus(json);
      case UsageProvider.crof:
        return _parseCrof(json);
      case UsageProvider.deepgram:
        return _parseDeepgram(json);
      case UsageProvider.stepfun:
        return _parseStepFun(json);
      case UsageProvider.doubao:
        return _parseDoubao(json);
      case UsageProvider.amp:
        return _parseAmp(json);
      case UsageProvider.qoder:
        return _parseQoder(json);
      case UsageProvider.alibaba:
        return _parseAlibaba(json);
      case UsageProvider.t3chat:
        return _parseT3Chat(json);
      case UsageProvider.zenmux:
        return _parseZenMux(json);
      default:
        return _parseGeneric(json, provider);
    }
  }

  // --- Provider-specific parsers ---

  static UsageSnapshot _parseDeepSeek(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final balance = (data['balance'] as num?)?.toDouble() ?? 0;
    final totalBalance = (data['total_balance'] as num?)?.toDouble() ?? 0;
    final percent = totalBalance > 0 ? ((totalBalance - balance) / totalBalance * 100).toDouble() : 0.0;

    return UsageSnapshot(
      primary: RateWindow(usedPercent: percent.clamp(0.0, 100.0)),
      updatedAt: DateTime.now(),
      identity: ProviderIdentitySnapshot(
        providerID: UsageProvider.deepseek,
        loginMethod: 'Balance: \$${balance.toStringAsFixed(2)}',
      ),
    );
  }

  static UsageSnapshot _parseVenice(Map<String, dynamic> json) {
    final balance = (json['balance'] as num?)?.toDouble() ?? 0;
    return UsageSnapshot(
      primary: RateWindow(usedPercent: 0),
      updatedAt: DateTime.now(),
      identity: ProviderIdentitySnapshot(
        providerID: UsageProvider.venice,
        loginMethod: 'Balance: \$${balance.toStringAsFixed(2)}',
      ),
    );
  }

  static UsageSnapshot _parseOpenRouter(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final totalCredits = (data['total_credits'] as num?)?.toDouble() ?? 0;
    final totalUsage = (data['total_usage'] as num?)?.toDouble() ?? 0;
    final percent = totalCredits > 0 ? (totalUsage / totalCredits * 100).clamp(0, 100) : 0;

    return UsageSnapshot(
      primary: RateWindow(usedPercent: percent.toDouble()),
      updatedAt: DateTime.now(),
      identity: ProviderIdentitySnapshot(
        providerID: UsageProvider.openrouter,
        loginMethod: 'Balance: \$${(totalCredits - totalUsage).toStringAsFixed(2)}',
      ),
    );
  }

  static UsageSnapshot _parseGroq(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    double? percent;
    if (data is List && data.isNotEmpty) {
      final first = data[0] as Map<String, dynamic>;
      percent = (first['usage_percent'] as num?)?.toDouble();
    }
    return makeSimpleSnapshot(
      provider: UsageProvider.groq,
      primaryPercent: percent,
      loginMethod: 'API',
    );
  }

  static UsageSnapshot _parseElevenLabs(Map<String, dynamic> json) {
    final characterCount = (json['character_count'] as num?)?.toDouble() ?? 0;
    final characterLimit = (json['character_limit'] as num?)?.toDouble() ?? 1;
    final percent = (characterCount / characterLimit * 100).clamp(0, 100);

    return UsageSnapshot(
      primary: RateWindow(usedPercent: percent.toDouble()),
      updatedAt: DateTime.now(),
      identity: ProviderIdentitySnapshot(
        providerID: UsageProvider.elevenlabs,
        loginMethod: '${characterCount.toInt()}/${characterLimit.toInt()} chars',
      ),
    );
  }

  static UsageSnapshot _parseMoonshot(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final availableBalance = (data['available_balance'] as num?)?.toDouble() ?? 0;
    final voucherBalance = (data['voucher_balance'] as num?)?.toDouble() ?? 0;

    return UsageSnapshot(
      primary: RateWindow(usedPercent: 0),
      updatedAt: DateTime.now(),
      identity: ProviderIdentitySnapshot(
        providerID: UsageProvider.moonshot,
        loginMethod: 'Balance: ¥${availableBalance.toStringAsFixed(2)}',
      ),
    );
  }

  static UsageSnapshot _parseKimi(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final total = (data['total'] as num?)?.toDouble() ?? 0;
    final used = (data['used'] as num?)?.toDouble() ?? 0;
    final percent = total > 0 ? (used / total * 100).clamp(0, 100) : 0;

    return UsageSnapshot(
      primary: RateWindow(usedPercent: percent.toDouble()),
      updatedAt: DateTime.now(),
      identity: ProviderIdentitySnapshot(
        providerID: UsageProvider.kimi,
        loginMethod: '${used.toInt()}/${total.toInt()} tokens',
      ),
    );
  }

  static UsageSnapshot _parseKimiK2(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final credits = (data['credits'] as num?)?.toDouble() ?? 0;
    return UsageSnapshot(
      primary: RateWindow(usedPercent: 0),
      updatedAt: DateTime.now(),
      identity: ProviderIdentitySnapshot(
        providerID: UsageProvider.kimik2,
        loginMethod: 'Credits: ${credits.toStringAsFixed(2)}',
      ),
    );
  }

  static UsageSnapshot _parsePoe(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final balance = (data['balance'] as num?)?.toDouble() ?? 0;
    return UsageSnapshot(
      primary: RateWindow(usedPercent: 0),
      updatedAt: DateTime.now(),
      identity: ProviderIdentitySnapshot(
        providerID: UsageProvider.poe,
        loginMethod: 'Balance: ${balance.toStringAsFixed(0)} points',
      ),
    );
  }

  static UsageSnapshot _parseWarp(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final requestsUsed = (data['requestsUsed'] as num?)?.toDouble() ?? 0;
    final requestsLimit = (data['requestsLimit'] as num?)?.toDouble() ?? 1;
    final percent = (requestsUsed / requestsLimit * 100).clamp(0, 100);

    return UsageSnapshot(
      primary: RateWindow(usedPercent: percent.toDouble()),
      updatedAt: DateTime.now(),
      identity: ProviderIdentitySnapshot(
        providerID: UsageProvider.warp,
        loginMethod: '${requestsUsed.toInt()}/${requestsLimit.toInt()} requests',
      ),
    );
  }

  static UsageSnapshot _parseManus(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final credits = (data['credits'] as num?)?.toDouble() ?? 0;
    return UsageSnapshot(
      primary: RateWindow(usedPercent: 0),
      updatedAt: DateTime.now(),
      identity: ProviderIdentitySnapshot(
        providerID: UsageProvider.manus,
        loginMethod: 'Credits: ${credits.toStringAsFixed(0)}',
      ),
    );
  }

  static UsageSnapshot _parseKilo(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final credits = (data['credits'] as num?)?.toDouble() ?? 0;
    return UsageSnapshot(
      primary: RateWindow(usedPercent: 0),
      updatedAt: DateTime.now(),
      identity: ProviderIdentitySnapshot(
        providerID: UsageProvider.kilo,
        loginMethod: 'Credits: ${credits.toStringAsFixed(0)}',
      ),
    );
  }

  static UsageSnapshot _parseAbacus(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final points = (data['computePoints'] as num?)?.toDouble() ?? 0;
    return UsageSnapshot(
      primary: RateWindow(usedPercent: 0),
      updatedAt: DateTime.now(),
      identity: ProviderIdentitySnapshot(
        providerID: UsageProvider.abacus,
        loginMethod: 'Points: ${points.toStringAsFixed(0)}',
      ),
    );
  }

  static UsageSnapshot _parseCrof(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final percent = (data['usage_percent'] as num?)?.toDouble() ?? 0;
    return makeSimpleSnapshot(
      provider: UsageProvider.crof,
      primaryPercent: percent,
      loginMethod: 'API',
    );
  }

  static UsageSnapshot _parseDeepgram(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final projects = data['projects'] as List?;
    if (projects != null && projects.isNotEmpty) {
      final project = projects[0] as Map<String, dynamic>;
      final usage = (project['usage'] as num?)?.toDouble() ?? 0;
      final limit = (project['limit'] as num?)?.toDouble() ?? 1;
      final percent = (usage / limit * 100).clamp(0, 100);
      return makeSimpleSnapshot(
        provider: UsageProvider.deepgram,
        primaryPercent: percent.toDouble(),
        loginMethod: 'API',
      );
    }
    return makeSimpleSnapshot(provider: UsageProvider.deepgram, loginMethod: 'API');
  }

  static UsageSnapshot _parseStepFun(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final percent = (data['usage_percent'] as num?)?.toDouble() ?? 0;
    return makeSimpleSnapshot(
      provider: UsageProvider.stepfun,
      primaryPercent: percent,
      loginMethod: 'API',
    );
  }

  static UsageSnapshot _parseDoubao(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final percent = (data['usage_percent'] as num?)?.toDouble() ?? 0;
    return makeSimpleSnapshot(
      provider: UsageProvider.doubao,
      primaryPercent: percent,
      loginMethod: 'API',
    );
  }

  static UsageSnapshot _parseAmp(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final balance = (data['balance'] as num?)?.toDouble() ?? 0;
    return UsageSnapshot(
      primary: RateWindow(usedPercent: 0),
      updatedAt: DateTime.now(),
      identity: ProviderIdentitySnapshot(
        providerID: UsageProvider.amp,
        loginMethod: 'Balance: \$${balance.toStringAsFixed(2)}',
      ),
    );
  }

  static UsageSnapshot _parseQoder(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final credits = (data['credits'] as num?)?.toDouble() ?? 0;
    return UsageSnapshot(
      primary: RateWindow(usedPercent: 0),
      updatedAt: DateTime.now(),
      identity: ProviderIdentitySnapshot(
        providerID: UsageProvider.qoder,
        loginMethod: 'Credits: ${credits.toStringAsFixed(0)}',
      ),
    );
  }

  static UsageSnapshot _parseAlibaba(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final percent = (data['usage_percent'] as num?)?.toDouble() ?? 0;
    return makeSimpleSnapshot(
      provider: UsageProvider.alibaba,
      primaryPercent: percent,
      loginMethod: 'API',
    );
  }

  static UsageSnapshot _parseT3Chat(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final credits = (data['credits'] as num?)?.toDouble() ?? 0;
    return UsageSnapshot(
      primary: RateWindow(usedPercent: 0),
      updatedAt: DateTime.now(),
      identity: ProviderIdentitySnapshot(
        providerID: UsageProvider.t3chat,
        loginMethod: 'Credits: ${credits.toStringAsFixed(0)}',
      ),
    );
  }

  static UsageSnapshot _parseZenMux(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final percent = (data['usage_percent'] as num?)?.toDouble() ?? 0;
    return makeSimpleSnapshot(
      provider: UsageProvider.zenmux,
      primaryPercent: percent,
      loginMethod: 'API',
    );
  }

  static UsageSnapshot _parseGeneric(Map<String, dynamic> json, UsageProvider provider) {
    double? percent;

    // Try common fields
    for (final key in ['usage_percent', 'used_percent', 'percent', 'usage', 'quota_used']) {
      final value = json[key];
      if (value is num) {
        percent = value.toDouble();
        break;
      }
      if (value is Map) {
        percent = (value['percent'] as num?)?.toDouble();
        break;
      }
    }

    // Try nested data
    if (percent == null && json['data'] is Map) {
      final data = json['data'] as Map<String, dynamic>;
      percent = (data['usage_percent'] as num?)?.toDouble() ??
          (data['used_percent'] as num?)?.toDouble() ??
          (data['percent'] as num?)?.toDouble();

      if (percent == null) {
        final usage = data['usage'];
        if (usage is Map) {
          percent = (usage['percent'] as num?)?.toDouble();
        }
      }
    }

    // Normalize 0-1 to 0-100
    if (percent != null && percent > 0 && percent < 1) {
      percent = percent * 100;
    }

    return makeSimpleSnapshot(
      provider: provider,
      primaryPercent: percent,
      loginMethod: 'API',
    );
  }
}

/// Generic API fetch strategy that uses ProviderEndpoints for correct URLs.
class ProviderAPIFetchStrategy extends FetchStrategy {
  @override
  final String id;
  @override
  final ProviderFetchKind kind = ProviderFetchKind.apiToken;
  final UsageProvider provider;

  ProviderAPIFetchStrategy({required this.id, required this.provider});

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    final envVar = ProviderEndpoints.getEnvVar(provider);
    if (envVar == null) return false;
    final env = context.env.isEmpty ? Platform.environment : context.env;
    return env[envVar]?.trim().isNotEmpty == true;
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final envVar = ProviderEndpoints.getEnvVar(provider)!;
    final env = context.env.isEmpty ? Platform.environment : context.env;
    final token = env[envVar]?.trim();
    if (token == null || token.isEmpty) {
      throw Exception('No $envVar found for ${provider.displayName}');
    }

    final endpoint = ProviderEndpoints.getEndpoint(provider);
    if (endpoint == null) {
      throw Exception('No API endpoint for ${provider.displayName}');
    }

    final authHeader = ProviderEndpoints.getAuthHeader(provider, token);
    final headers = {
      'Authorization': authHeader,
      'Accept': 'application/json',
    };

    DebugLogger.request(provider.displayName, 'GET', endpoint, headers: headers);

    final response = await http.get(Uri.parse(endpoint), headers: headers);
    DebugLogger.response(provider.displayName, endpoint, response.statusCode, response.body);

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Invalid API key for ${provider.displayName}');
    }
    if (response.statusCode != 200) {
      throw Exception('${provider.displayName} API error: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final snapshot = ProviderEndpoints.parseResponse(provider, json);

    return ProviderFetchResult(
      usage: snapshot,
      sourceLabel: 'api',
      strategyID: id,
      strategyKind: kind,
    );
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => false;
}
