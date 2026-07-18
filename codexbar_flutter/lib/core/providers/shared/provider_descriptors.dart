import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../auth/browser_cookie_resolver.dart';
import '../../debug/debug_logger.dart';
import '../../models/fetch_kind.dart';
import '../../models/fetch_result.dart';
import '../../models/provider_branding.dart';
import '../../models/provider_identity.dart';
import '../../models/provider_metadata.dart';
import '../../models/rate_window.dart';
import '../../models/usage_provider.dart';
import '../../models/usage_snapshot.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'generic_api_strategy.dart';

/// All remaining provider descriptors.
/// Uses generic strategies to avoid code duplication.
class AllProviderDescriptors {
  static List<ProviderDescriptor> get all => [
        _gemini,
        _copilot,
        _cursor,
        _mistral,
        _perplexity,
        _ollama,
        _bedrock,
        _vertexai,
        _jetbrains,
        _antigravity,
        _factory,
        _devin,
        _manus,
        _augment,
        _windsurf,
        _kiro,
        _warp,
        _grok,
        _qoder,
        _minimax,
        _kimi,
        _kimik2,
        _alibaba,
        _doubao,
        _stepfun,
        _venice,
        _crof,
        _poe,
        _codebuff,
        _kilo,
        _deepgram,
        _mimo,
        _t3chat,
        _zed,
        _sakana,
        _abacus,
        _chutes,
        _sub2api,
        _wayfinder,
        _zenmux,
        _openai,
        _azureopenai,
        _opencode,
        _opencodego,
        _commandcode,
      ];

  // --- API Key Providers ---

  static final _warp = _apiProvider(
    id: UsageProvider.warp,
    displayName: 'Warp',
    envVar: 'WARP_API_KEY',
    color: 0xFF00D4AA,
    cliName: 'warp',
  );

  static final _doubao = _apiProvider(
    id: UsageProvider.doubao,
    displayName: 'Doubao',
    envVar: 'DOUBAO_API_KEY',
    color: 0xFF0088FF,
    cliName: 'doubao',
  );

  static final _stepfun = _apiProvider(
    id: UsageProvider.stepfun,
    displayName: 'StepFun',
    envVar: 'STEPFUN_TOKEN',
    color: 0xFF9B59B6,
    cliName: 'stepfun',
  );

  static final _venice = _apiProvider(
    id: UsageProvider.venice,
    displayName: 'Venice',
    envVar: 'VENICE_API_KEY',
    color: 0xFF6C5CE7,
    cliName: 'venice',
  );

  static final _crof = _apiProvider(
    id: UsageProvider.crof,
    displayName: 'Crof',
    envVar: 'CROF_API_KEY',
    color: 0xFF2ECC71,
    cliName: 'crof',
  );

  static final _poe = _apiProvider(
    id: UsageProvider.poe,
    displayName: 'Poe',
    envVar: 'POE_API_KEY',
    color: 0xFF6C5CE7,
    cliName: 'poe',
  );

  static final _kimi = _apiProvider(
    id: UsageProvider.kimi,
    displayName: 'Kimi',
    envVar: 'KIMI_AUTH_TOKEN',
    color: 0xFF0088FF,
    cliName: 'kimi',
    altEnvVar: 'KIMI_API_KEY',
  );

  static final _kimik2 = _apiProvider(
    id: UsageProvider.kimik2,
    displayName: 'Kimi K2',
    envVar: 'KIMI_K2_API_KEY',
    color: 0xFF0088FF,
    cliName: 'kimik2',
  );

  static final _minimax = _apiProvider(
    id: UsageProvider.minimax,
    displayName: 'MiniMax',
    envVar: 'MINIMAX_API_TOKEN',
    color: 0xFFFF6B35,
    cliName: 'minimax',
  );

  static final _alibaba = _apiProvider(
    id: UsageProvider.alibaba,
    displayName: 'Alibaba',
    envVar: 'ALIBABA_API_TOKEN',
    color: 0xFFFF6A00,
    cliName: 'alibaba',
  );

  static final _deepgram = _apiProvider(
    id: UsageProvider.deepgram,
    displayName: 'Deepgram',
    envVar: 'DEEPGRAM_API_KEY',
    color: 0xFF1A1A2E,
    cliName: 'deepgram',
  );

  static final _codebuff = _apiProvider(
    id: UsageProvider.codebuff,
    displayName: 'Codebuff',
    envVar: 'CODEBUFF_API_KEY',
    color: 0xFF3498DB,
    cliName: 'codebuff',
  );

  static final _kilo = _apiProvider(
    id: UsageProvider.kilo,
    displayName: 'Kilo',
    envVar: 'KILO_API_KEY',
    color: 0xFFF39C12,
    cliName: 'kilo',
  );

  // --- Browser Cookie Providers ---

  static final _cursor = _cookieProvider(
    id: UsageProvider.cursor,
    displayName: 'Cursor',
    color: 0xFF000000,
    cliName: 'cursor',
    apiDomain: 'cursor.com',
  );

  static final _factory = _cookieProvider(
    id: UsageProvider.factory,
    displayName: 'Factory',
    color: 0xFF2ECC71,
    cliName: 'factory',
    apiDomain: 'factory.ai',
  );

  static final _devin = _cookieProvider(
    id: UsageProvider.devin,
    displayName: 'Devin',
    color: 0xFF6C5CE7,
    cliName: 'devin',
    apiDomain: 'devin.ai',
  );

  static final _manus = _cookieProvider(
    id: UsageProvider.manus,
    displayName: 'Manus',
    color: 0xFF000000,
    cliName: 'manus',
    apiDomain: 'manus.im',
  );

  static final _grok = _cookieProvider(
    id: UsageProvider.grok,
    displayName: 'Grok',
    color: 0xFF1DA1F2,
    cliName: 'grok',
    apiDomain: 'grok.com',
  );

  static final _qoder = _cookieProvider(
    id: UsageProvider.qoder,
    displayName: 'Qoder',
    color: 0xFF9B59B6,
    cliName: 'qoder',
    apiDomain: 'qoder.ai',
  );

  static final _mistral = _cookieProvider(
    id: UsageProvider.mistral,
    displayName: 'Mistral',
    color: 0xFFFF7F00,
    cliName: 'mistral',
    apiDomain: 'mistral.ai',
  );

  static final _augment = _cookieProvider(
    id: UsageProvider.augment,
    displayName: 'Augment',
    color: 0xFF6C5CE7,
    cliName: 'augment',
    apiDomain: 'augmentcode.com',
  );

  static final _windsurf = _cookieProvider(
    id: UsageProvider.windsurf,
    displayName: 'Windsurf',
    color: 0xFF00D4AA,
    cliName: 'windsurf',
    apiDomain: 'windsurf.com',
  );

  static final _commandcode = _cookieProvider(
    id: UsageProvider.commandcode,
    displayName: 'Command Code',
    color: 0xFF3498DB,
    cliName: 'commandcode',
    apiDomain: 'commandcode.dev',
  );

  static final _kiro = _cookieProvider(
    id: UsageProvider.kiro,
    displayName: 'Kiro',
    color: 0xFFFF9900,
    cliName: 'kiro',
    apiDomain: 'kiro.dev',
  );

  static final _copilot = _cookieProvider(
    id: UsageProvider.copilot,
    displayName: 'Copilot',
    color: 0xFF000000,
    cliName: 'copilot',
    apiDomain: 'github.com',
    envVar: 'COPILOT_API_TOKEN',
  );

  static final _perplexity = _cookieProvider(
    id: UsageProvider.perplexity,
    displayName: 'Perplexity',
    color: 0xFF1B7CED,
    cliName: 'perplexity',
    apiDomain: 'perplexity.ai',
    envVar: 'PERPLEXITY_SESSION_TOKEN',
  );

  // --- Special Providers ---

  static final _gemini = ProviderDescriptor(
    id: UsageProvider.gemini,
    metadata: const ProviderMetadata(
      id: UsageProvider.gemini,
      displayName: 'Gemini',
      sessionLabel: 'Usage',
      weeklyLabel: 'Quota',
      supportsOpus: false,
      toggleTitle: 'Show Gemini usage',
      cliName: 'gemini',
      defaultEnabled: false,
    ),
    branding: const ProviderBranding(
      iconStyle: 'gemini',
      iconResourceName: 'ProviderIcon-gemini',
      colorValue: 0xFF4285F4,
    ),
    pipeline: FetchPipeline(
      resolveStrategies: (context) async => [_GeminiWebStrategy()],
    ),
    cliName: 'gemini',
  );

  static final _ollama = ProviderDescriptor(
    id: UsageProvider.ollama,
    metadata: const ProviderMetadata(
      id: UsageProvider.ollama,
      displayName: 'Ollama',
      sessionLabel: 'Local',
      weeklyLabel: 'Models',
      supportsOpus: false,
      toggleTitle: 'Show Ollama status',
      cliName: 'ollama',
      defaultEnabled: false,
    ),
    branding: const ProviderBranding(
      iconStyle: 'ollama',
      iconResourceName: 'ProviderIcon-ollama',
      colorValue: 0xFFFFFFFF,
    ),
    pipeline: FetchPipeline(
      resolveStrategies: (context) async => [_OllamaLocalStrategy()],
    ),
    cliName: 'ollama',
  );

  static final _bedrock = ProviderDescriptor(
    id: UsageProvider.bedrock,
    metadata: const ProviderMetadata(
      id: UsageProvider.bedrock,
      displayName: 'Bedrock',
      sessionLabel: 'Usage',
      weeklyLabel: 'Quota',
      supportsOpus: false,
      toggleTitle: 'Show Bedrock usage',
      cliName: 'bedrock',
      defaultEnabled: false,
    ),
    branding: const ProviderBranding(
      iconStyle: 'bedrock',
      iconResourceName: 'ProviderIcon-bedrock',
      colorValue: 0xFFFF9900,
    ),
    pipeline: FetchPipeline(
      resolveStrategies: (context) async {
        final strategies = <FetchStrategy>[];
        if (Platform.environment['AWS_ACCESS_KEY_ID']?.isNotEmpty == true) {
          strategies.add(_BedrockStrategy());
        }
        return strategies;
      },
    ),
    cliName: 'bedrock',
  );

  static final _vertexai = _simpleProvider(
    id: UsageProvider.vertexai,
    displayName: 'Vertex AI',
    color: 0xFF4285F4,
    cliName: 'vertexai',
  );

  static final _jetbrains = _simpleProvider(
    id: UsageProvider.jetbrains,
    displayName: 'JetBrains',
    color: 0xFF000000,
    cliName: 'jetbrains',
  );

  static final _antigravity = _simpleProvider(
    id: UsageProvider.antigravity,
    displayName: 'Antigravity',
    color: 0xFF6C5CE7,
    cliName: 'antigravity',
  );

  static final _sakana = _simpleProvider(
    id: UsageProvider.sakana,
    displayName: 'Sakana',
    color: 0xFF2ECC71,
    cliName: 'sakana',
  );

  static final _abacus = _simpleProvider(
    id: UsageProvider.abacus,
    displayName: 'Abacus',
    color: 0xFFE74C3C,
    cliName: 'abacus',
  );

  static final _chutes = _simpleProvider(
    id: UsageProvider.chutes,
    displayName: 'Chutes',
    color: 0xFF9B59B6,
    cliName: 'chutes',
  );

  static final _sub2api = _simpleProvider(
    id: UsageProvider.sub2api,
    displayName: 'Sub2API',
    color: 0xFF3498DB,
    cliName: 'sub2api',
  );

  static final _wayfinder = _simpleProvider(
    id: UsageProvider.wayfinder,
    displayName: 'Wayfinder',
    color: 0xFFF39C12,
    cliName: 'wayfinder',
  );

  static final _zenmux = _simpleProvider(
    id: UsageProvider.zenmux,
    displayName: 'ZenMux',
    color: 0xFF1ABC9C,
    cliName: 'zenmux',
  );

  static final _mimo = _cookieProvider(
    id: UsageProvider.mimo,
    displayName: 'MiMo',
    color: 0xFFFF6B35,
    cliName: 'mimo',
    apiDomain: 'platform.xiaomimimo.com',
  );

  static final _t3chat = _simpleProvider(
    id: UsageProvider.t3chat,
    displayName: 'T3 Chat',
    color: 0xFF6C5CE7,
    cliName: 't3chat',
  );

  static final _zed = _simpleProvider(
    id: UsageProvider.zed,
    displayName: 'Zed',
    color: 0xFF000000,
    cliName: 'zed',
  );

  static final _openai = _simpleProvider(
    id: UsageProvider.openai,
    displayName: 'OpenAI',
    color: 0xFF0F8273,
    cliName: 'openai',
  );

  static final _azureopenai = _simpleProvider(
    id: UsageProvider.azureopenai,
    displayName: 'Azure OpenAI',
    color: 0xFF0078D4,
    cliName: 'azureopenai',
  );

  static final _opencode = _simpleProvider(
    id: UsageProvider.opencode,
    displayName: 'OpenCode',
    color: 0xFF2ECC71,
    cliName: 'opencode',
  );

  static final _opencodego = _simpleProvider(
    id: UsageProvider.opencodego,
    displayName: 'OpenCode Go',
    color: 0xFF00ADD8,
    cliName: 'opencodego',
  );

  // --- Helper Methods ---

  static ProviderDescriptor _apiProvider({
    required UsageProvider id,
    required String displayName,
    required String envVar,
    required int color,
    required String cliName,
    String? altEnvVar,
  }) {
    return ProviderDescriptor(
      id: id,
      metadata: ProviderMetadata(
        id: id,
        displayName: displayName,
        sessionLabel: 'Usage',
        weeklyLabel: 'Quota',
        supportsOpus: false,
        toggleTitle: 'Show $displayName usage',
        cliName: cliName,
        defaultEnabled: false,
      ),
      branding: ProviderBranding(
        iconStyle: id.name,
        iconResourceName: 'ProviderIcon-${id.name}',
        colorValue: color,
      ),
      pipeline: FetchPipeline(
        resolveStrategies: (context) async {
          final strategies = <FetchStrategy>[];
          final env = context.env.isEmpty ? Platform.environment : context.env;
          if (env[envVar]?.trim().isNotEmpty == true ||
              (altEnvVar != null && env[altEnvVar]?.trim().isNotEmpty == true)) {
            strategies.add(GenericAPIStrategy(
              id: '${id.name}.api',
              provider: id,
              envVarName: envVar,
              apiEndpoint: 'https://api.example.com/v1/usage', // Placeholder
              parseResponse: (json) => makeSimpleSnapshot(provider: id),
            ));
          }
          return strategies;
        },
      ),
      cliName: cliName,
    );
  }

  static ProviderDescriptor _cookieProvider({
    required UsageProvider id,
    required String displayName,
    required int color,
    required String cliName,
    required String apiDomain,
    String? envVar,
  }) {
    return ProviderDescriptor(
      id: id,
      metadata: ProviderMetadata(
        id: id,
        displayName: displayName,
        sessionLabel: 'Usage',
        weeklyLabel: 'Quota',
        supportsOpus: false,
        toggleTitle: 'Show $displayName usage',
        cliName: cliName,
        defaultEnabled: false,
      ),
      branding: ProviderBranding(
        iconStyle: id.name,
        iconResourceName: 'ProviderIcon-${id.name}',
        colorValue: color,
      ),
      pipeline: FetchPipeline(
        resolveStrategies: (context) async {
          final strategies = <FetchStrategy>[];
          // Cookie strategy (always add - it tries DB, CDP, and manual cookies)
          strategies.add(_GenericCookieStrategy(
            provider: id,
            apiDomain: apiDomain,
          ));
          // API key strategy (if env var provided)
          if (envVar != null) {
            final env = context.env.isEmpty ? Platform.environment : context.env;
            if (env[envVar]?.trim().isNotEmpty == true) {
              strategies.add(GenericAPIStrategy(
                id: '${id.name}.api',
                provider: id,
                envVarName: envVar,
                apiEndpoint: 'https://$apiDomain/api/usage',
                parseResponse: (json) => makeSimpleSnapshot(provider: id),
              ));
            }
          }
          return strategies;
        },
      ),
      cliName: cliName,
    );
  }

  static ProviderDescriptor _simpleProvider({
    required UsageProvider id,
    required String displayName,
    required int color,
    required String cliName,
  }) {
    return ProviderDescriptor(
      id: id,
      metadata: ProviderMetadata(
        id: id,
        displayName: displayName,
        sessionLabel: 'Usage',
        weeklyLabel: 'Quota',
        supportsOpus: false,
        toggleTitle: 'Show $displayName usage',
        cliName: cliName,
        defaultEnabled: false,
      ),
      branding: ProviderBranding(
        iconStyle: id.name,
        iconResourceName: 'ProviderIcon-${id.name}',
        colorValue: color,
      ),
      pipeline: FetchPipeline(
        resolveStrategies: (context) async => [],
      ),
      cliName: cliName,
    );
  }
}

/// Generic cookie-based fetch strategy with provider-specific API endpoints.
class _GenericCookieStrategy extends FetchStrategy {
  final UsageProvider provider;
  final String apiDomain;

  _GenericCookieStrategy({required this.provider, required this.apiDomain});

  @override
  String get id => '${provider.name}.web';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.web;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    return true;
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    DebugLogger.log('FetchStrategy', '${provider.displayName} fetch() started');
    final env = context.env.isEmpty ? Platform.environment : context.env;
    String? cookieHeader;

    // 1. Try manually configured cookie from environment
    final manualCookie = env['${provider.name.toUpperCase()}_COOKIE'];
    if (manualCookie != null && manualCookie.trim().isNotEmpty) {
      cookieHeader = manualCookie.trim();
      DebugLogger.log('FetchStrategy', '  Using manual cookie from env');
    }

    // 2. Try browser cookie resolver (sequential browser check)
    if (cookieHeader == null || cookieHeader.isEmpty) {
      DebugLogger.log('FetchStrategy', '  Trying browser cookie resolver...');
      final resolver = BrowserCookieResolver();
      final cookies = await resolver.resolve(provider);
      cookieHeader = cookies?.cookieHeader;
      if (cookies != null) {
        DebugLogger.log('FetchStrategy', '  Got cookies from ${cookies.browser.displayName}');
      }
    }

    if (cookieHeader == null || cookieHeader.isEmpty) {
      DebugLogger.error('FetchStrategy', 'No cookies found for ${provider.displayName}');
      throw Exception(
        'No cookies found for ${provider.displayName}. '
        'Open the provider website in your browser and sign in.',
      );
    }

    // 3. Try provider-specific API endpoints
    DebugLogger.log('FetchStrategy', '  Calling provider-specific API...');
    return await _fetchWithCookies(cookieHeader);
  }

  Future<ProviderFetchResult> _fetchWithCookies(String cookieHeader) async {
    final headers = {
      'Cookie': cookieHeader,
      'Accept': 'application/json',
    };

    // Provider-specific endpoints and parsing
    switch (provider) {
      case UsageProvider.mimo:
        return _fetchMiMo(headers);
      case UsageProvider.minimax:
        return _fetchMiniMax(headers);
      case UsageProvider.zai:
        return _fetchZai(headers);
      case UsageProvider.claude:
        return _fetchClaude(headers);
      case UsageProvider.openai:
        return _fetchOpenAI(headers);
      case UsageProvider.cursor:
        return _fetchCursor(headers);
      default:
        return _fetchGeneric(headers);
    }
  }

  Future<ProviderFetchResult> _fetchMiMo(Map<String, String> headers) async {
    const url = 'https://platform.xiaomimimo.com/api/user/usage';
    DebugLogger.request('MiMo', 'GET', url, headers: headers);

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      DebugLogger.response('MiMo', url, response.statusCode, response.body);

      if (response.statusCode == 200) {
        final json = _decodeResponse(response.body);
        if (json != null) {
          DebugLogger.log('MiMo', 'Parsing usage response...');
          return ProviderFetchResult(
            usage: _parseGenericUsage(json, provider),
            sourceLabel: 'web',
            strategyID: id,
            strategyKind: kind,
          );
        } else {
          DebugLogger.error('MiMo', 'Failed to decode response body');
        }
      } else {
        DebugLogger.error('MiMo', 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      DebugLogger.error('MiMo', 'Request failed', e);
    }

    DebugLogger.log('MiMo', 'Returning cookie-only snapshot');
    return ProviderFetchResult(
      usage: makeSimpleSnapshot(provider: provider, loginMethod: 'cookie'),
      sourceLabel: 'web:cookie',
      strategyID: id,
      strategyKind: kind,
    );
  }

  Future<ProviderFetchResult> _fetchMiniMax(Map<String, String> headers) async {
    const url = 'https://api.minimax.chat/v1/user/info';
    DebugLogger.request('MiniMax', 'GET', url, headers: headers);

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      DebugLogger.response('MiniMax', url, response.statusCode, response.body);

      if (response.statusCode == 200) {
        final json = _decodeResponse(response.body);
        if (json != null) {
          return ProviderFetchResult(
            usage: _parseGenericUsage(json, provider),
            sourceLabel: 'web',
            strategyID: id,
            strategyKind: kind,
          );
        }
      }
    } catch (e) {
      DebugLogger.error('MiniMax', 'Request failed', e);
    }

    return ProviderFetchResult(
      usage: makeSimpleSnapshot(provider: provider, loginMethod: 'cookie'),
      sourceLabel: 'web:cookie',
      strategyID: id,
      strategyKind: kind,
    );
  }

  Future<ProviderFetchResult> _fetchZai(Map<String, String> headers) async {
    const url = 'https://api.z.ai/api/monitor/usage/quota/limit';
    DebugLogger.request('Zai', 'GET', url, headers: headers);

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      DebugLogger.response('Zai', url, response.statusCode, response.body);

      if (response.statusCode == 200) {
        final json = _decodeResponse(response.body);
        if (json != null) {
          return ProviderFetchResult(
            usage: _parseGenericUsage(json, provider),
            sourceLabel: 'web',
            strategyID: id,
            strategyKind: kind,
          );
        }
      }
    } catch (e) {
      DebugLogger.error('Zai', 'Request failed', e);
    }

    return ProviderFetchResult(
      usage: makeSimpleSnapshot(provider: provider, loginMethod: 'cookie'),
      sourceLabel: 'web:cookie',
      strategyID: id,
      strategyKind: kind,
    );
  }

  Future<ProviderFetchResult> _fetchClaude(Map<String, String> headers) async {
    const orgUrl = 'https://claude.ai/api/organizations';
    DebugLogger.request('Claude', 'GET', orgUrl, headers: headers);

    try {
      final orgResponse = await http.get(Uri.parse(orgUrl), headers: headers);
      DebugLogger.response('Claude', orgUrl, orgResponse.statusCode, orgResponse.body, maxLength: 300);

      if (orgResponse.statusCode == 200) {
        final orgsData = jsonDecode(orgResponse.body);
        if (orgsData is List && orgsData.isNotEmpty) {
          final org = orgsData[0] as Map<String, dynamic>;
          final orgId = org['uuid'] as String?;
          DebugLogger.log('Claude', 'Organization ID: $orgId');

          if (orgId != null) {
            final usageUrl = 'https://claude.ai/api/organizations/$orgId/usage';
            DebugLogger.request('Claude', 'GET', usageUrl, headers: headers);

            final usageResponse = await http.get(Uri.parse(usageUrl), headers: headers);
            DebugLogger.response('Claude', usageUrl, usageResponse.statusCode, usageResponse.body);

            if (usageResponse.statusCode == 200) {
              final usageJson = _decodeResponse(usageResponse.body);
              if (usageJson != null) {
                DebugLogger.log('Claude', 'Parsing Claude usage response...');
                return ProviderFetchResult(
                  usage: _parseClaudeUsage(usageJson, org),
                  sourceLabel: 'web',
                  strategyID: id,
                  strategyKind: kind,
                );
              } else {
                DebugLogger.error('Claude', 'Failed to decode usage response');
              }
            } else {
              DebugLogger.error('Claude', 'Usage API returned ${usageResponse.statusCode}');
            }
          }
        } else {
          DebugLogger.error('Claude', 'No organizations found in response');
        }
      } else {
        DebugLogger.error('Claude', 'Organizations API returned ${orgResponse.statusCode}');
      }
    } catch (e) {
      DebugLogger.error('Claude', 'Request failed', e);
    }

    DebugLogger.log('Claude', 'Returning cookie-only snapshot');
    return ProviderFetchResult(
      usage: makeSimpleSnapshot(provider: provider, loginMethod: 'cookie'),
      sourceLabel: 'web:cookie',
      strategyID: id,
      strategyKind: kind,
    );
  }

  Future<ProviderFetchResult> _fetchOpenAI(Map<String, String> headers) async {
    DebugLogger.log('OpenAI', 'Cookie-based fetch not yet implemented, returning cookie snapshot');
    return ProviderFetchResult(
      usage: makeSimpleSnapshot(provider: provider, loginMethod: 'cookie'),
      sourceLabel: 'web:cookie',
      strategyID: id,
      strategyKind: kind,
    );
  }

  Future<ProviderFetchResult> _fetchCursor(Map<String, String> headers) async {
    DebugLogger.log('Cursor', 'Cookie-based fetch not yet implemented, returning cookie snapshot');
    return ProviderFetchResult(
      usage: makeSimpleSnapshot(provider: provider, loginMethod: 'cookie'),
      sourceLabel: 'web:cookie',
      strategyID: id,
      strategyKind: kind,
    );
  }

  Future<ProviderFetchResult> _fetchGeneric(Map<String, String> headers) async {
    DebugLogger.log(provider.displayName, 'Trying generic API endpoints');

    final endpoints = [
      'https://$apiDomain/api/usage',
      'https://$apiDomain/api/user/usage',
      'https://$apiDomain/api/v1/usage',
      'https://$apiDomain/api/account/usage',
    ];

    for (final endpoint in endpoints) {
      DebugLogger.request(provider.displayName, 'GET', endpoint, headers: headers);
      try {
        final response = await http.get(Uri.parse(endpoint), headers: headers);
        DebugLogger.response(provider.displayName, endpoint, response.statusCode, response.body);

        if (response.statusCode == 200) {
          final json = _decodeResponse(response.body);
          if (json != null) {
            return ProviderFetchResult(
              usage: _parseGenericUsage(json, provider),
              sourceLabel: 'web',
              strategyID: id,
              strategyKind: kind,
            );
          }
        }
      } catch (e) {
        DebugLogger.error(provider.displayName, 'Endpoint $endpoint failed', e);
      }
    }

    DebugLogger.log(provider.displayName, 'No working endpoint found, returning cookie snapshot');
    return ProviderFetchResult(
      usage: makeSimpleSnapshot(provider: provider, loginMethod: 'cookie'),
      sourceLabel: 'web:cookie',
      strategyID: id,
      strategyKind: kind,
    );
  }

  Map<String, dynamic>? _decodeResponse(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is List && decoded.isNotEmpty) {
        return {'data': decoded};
      }
    } catch (_) {}
    return null;
  }

  UsageSnapshot _parseGenericUsage(Map<String, dynamic> json, UsageProvider provider) {
    // Try to extract usage info from common response formats
    double? percent;
    DateTime? resetsAt;

    // Try various common fields
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
          (data['used_percent'] as num?)?.toDouble();
    }

    return makeSimpleSnapshot(
      provider: provider,
      primaryPercent: percent,
      loginMethod: 'cookie',
    );
  }

  UsageSnapshot _parseClaudeUsage(Map<String, dynamic> json, Map<String, dynamic> org) {
    RateWindow? primary;
    RateWindow? secondary;

    final rateLimit = json['rate_limit'] as Map<String, dynamic>?;
    if (rateLimit?['five_hour'] != null) {
      final fiveHour = rateLimit!['five_hour'] as Map<String, dynamic>;
      primary = RateWindow(
        usedPercent: (fiveHour['used_percent'] as num?)?.toDouble() ?? 0,
        windowMinutes: 300,
        resetsAt: fiveHour['resets_at'] != null
            ? DateTime.tryParse(fiveHour['resets_at'] as String)
            : null,
      );
    }
    if (rateLimit?['seven_day'] != null) {
      final sevenDay = rateLimit!['seven_day'] as Map<String, dynamic>;
      secondary = RateWindow(
        usedPercent: (sevenDay['used_percent'] as num?)?.toDouble() ?? 0,
        windowMinutes: 10080,
        resetsAt: sevenDay['resets_at'] != null
            ? DateTime.tryParse(sevenDay['resets_at'] as String)
            : null,
      );
    }

    return UsageSnapshot(
      primary: primary,
      secondary: secondary,
      updatedAt: DateTime.now(),
      identity: ProviderIdentitySnapshot(
        providerID: UsageProvider.claude,
        accountEmail: org['email'] as String?,
        accountOrganization: org['name'] as String?,
        loginMethod: 'cookie',
      ),
    );
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => true;
}

/// Gemini web strategy.
class _GeminiWebStrategy extends FetchStrategy {
  @override
  String get id => 'gemini.web';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.web;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    final resolver = BrowserCookieResolver();
    return await resolver.hasPlausibleSession(UsageProvider.gemini);
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    return ProviderFetchResult(
      usage: makeSimpleSnapshot(provider: UsageProvider.gemini),
      sourceLabel: 'web:placeholder',
      strategyID: id,
      strategyKind: kind,
    );
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => true;
}

/// Ollama local strategy.
class _OllamaLocalStrategy extends FetchStrategy {
  @override
  String get id => 'ollama.local';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.localProbe;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:11434/api/tags'))
          .timeout(const Duration(seconds: 2));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    await http.get(Uri.parse('http://localhost:11434/api/tags'));

    return ProviderFetchResult(
      usage: makeSimpleSnapshot(
        provider: UsageProvider.ollama,
        primaryPercent: 0,
      ),
      sourceLabel: 'local',
      strategyID: id,
      strategyKind: kind,
    );
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => false;
}

/// Bedrock strategy.
class _BedrockStrategy extends FetchStrategy {
  @override
  String get id => 'bedrock.api';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.apiToken;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    return Platform.environment['AWS_ACCESS_KEY_ID']?.isNotEmpty == true;
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    // Bedrock uses AWS SDK - placeholder implementation
    return ProviderFetchResult(
      usage: makeSimpleSnapshot(provider: UsageProvider.bedrock),
      sourceLabel: 'api:placeholder',
      strategyID: id,
      strategyKind: kind,
    );
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => false;
}
