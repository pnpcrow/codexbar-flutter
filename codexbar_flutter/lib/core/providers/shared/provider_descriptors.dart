import 'dart:io';

import 'package:http/http.dart' as http;

import '../../auth/browser_cookie_resolver.dart';
import '../../models/fetch_kind.dart';
import '../../models/fetch_result.dart';
import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
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

  static final _mimo = _simpleProvider(
    id: UsageProvider.mimo,
    displayName: 'MiMo',
    color: 0xFFFF6B35,
    cliName: 'mimo',
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
          // Cookie strategy
          final resolver = BrowserCookieResolver();
          if (await resolver.hasPlausibleSession(id)) {
            strategies.add(_GenericCookieStrategy(
              provider: id,
              apiDomain: apiDomain,
            ));
          }
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

/// Generic cookie-based fetch strategy.
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
    final resolver = BrowserCookieResolver();
    return await resolver.hasPlausibleSession(provider);
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final resolver = BrowserCookieResolver();
    final cookies = await resolver.resolve(provider);
    if (cookies == null) {
      throw Exception('No cookies found for ${provider.displayName}');
    }

    // Try to fetch usage from provider's web API
    try {
      final response = await http.get(
        Uri.parse('https://$apiDomain/api/usage'),
        headers: {'Cookie': cookies.cookieHeader},
      );

      if (response.statusCode == 200) {
        return ProviderFetchResult(
          usage: makeSimpleSnapshot(provider: provider),
          sourceLabel: 'web',
          strategyID: id,
          strategyKind: kind,
        );
      }
    } catch (_) {}

    // Return empty snapshot if fetch fails
    return ProviderFetchResult(
      usage: makeSimpleSnapshot(provider: provider),
      sourceLabel: 'web:placeholder',
      strategyID: id,
      strategyKind: kind,
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
