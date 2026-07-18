# Subagent Provider Implementation Task

## Your Task
Implement providers for the CodexBar Flutter port. Follow the patterns exactly.

## Reference Implementations
- `lib/core/providers/claude/` - CLI + Web cookie pattern
- `lib/core/providers/openai/` - API key pattern

## Required Files Per Provider
1. `<name>_descriptor.dart` - ProviderDescriptor with metadata
2. `<name>_fetch_strategy.dart` - FetchStrategy implementation(s)

## Pattern to Follow

### For API Key Providers (DeepSeek, Moonshot, etc.)
```dart
// Environment variable: PROVIDER_API_KEY
class ProviderFetchStrategy extends FetchStrategy {
  @override
  String get id => 'provider.api';
  @override
  ProviderFetchKind get kind => ProviderFetchKind.apiToken;
  
  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    return Platform.environment['PROVIDER_API_KEY']?.isNotEmpty == true;
  }
  
  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final apiKey = Platform.environment['PROVIDER_API_KEY']!;
    final response = await http.get(
      Uri.parse('https://api.provider.com/v1/usage'),
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    // Parse response to UsageSnapshot
    return ProviderFetchResult(usage: snapshot, sourceLabel: 'api', strategyID: id, strategyKind: kind);
  }
  
  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => false;
}
```

### For Browser Cookie Providers (Cursor, etc.)
```dart
class ProviderWebFetchStrategy extends FetchStrategy {
  @override
  String get id => 'provider.web';
  @override
  ProviderFetchKind get kind => ProviderFetchKind.web;
  
  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    final resolver = BrowserCookieResolver();
    return await resolver.hasPlausibleSession(UsageProvider.provider);
  }
  
  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final resolver = BrowserCookieResolver();
    final cookies = await resolver.resolve(UsageProvider.provider);
    // Use cookies to fetch from provider's web API
    return ProviderFetchResult(usage: snapshot, sourceLabel: 'web', strategyID: id, strategyKind: kind);
  }
  
  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => true;
}
```

## Environment Variables Reference
- DeepSeek: `DEEPSEEK_API_KEY`
- Moonshot: `MOONSHOT_API_KEY`
- Amp: `AMP_API_TOKEN`
- Zai: `ZAI_API_TOKEN`
- Synthetic: `SYNTHETIC_API_KEY`
- OpenRouter: `OPENROUTER_API_TOKEN`
- ElevenLabs: `ELEVENLABS_API_KEY`
- Groq: `GROQ_API_KEY`
- LLM Proxy: `LLMPROXY_API_KEY`
- LiteLLM: `LITELLM_API_KEY`
- ClawRouter: `CLAWROUTER_API_KEY`
- CrossModel: `CROSSMODEL_API_TOKEN`
- Warp: `WARP_API_KEY`
- Doubao: `DOUBAO_API_KEY`
- StepFun: `STEPFUN_TOKEN`
- Venice: `VENICE_API_KEY`
- Crof: `CROF_API_KEY`
- Poe: `POE_API_KEY`
- Kimi: `KIMI_AUTH_TOKEN` or `KIMI_API_KEY`
- Kimi K2: `KIMI_K2_API_KEY`
- MiniMax: `MINIMAX_API_TOKEN`
- Alibaba: `ALIBABA_API_TOKEN`
- Perplexity: `PERPLEXITY_SESSION_TOKEN`
- Deepgram: `DEEPGRAM_API_KEY`
- Codebuff: `CODEBUFF_API_KEY`
- Kilo: `KILO_API_KEY`

## Registration
After implementing, add to `lib/main.dart`:
```dart
registry.register(ProviderDescriptor.descriptor);
```

## Checklist
- [ ] Create directory: `lib/core/providers/<name>/`
- [ ] Create `<name>_descriptor.dart` with correct metadata
- [ ] Create `<name>_fetch_strategy.dart` with fetch logic
- [ ] Run `flutter analyze` - must have 0 errors
- [ ] Add registration in `main.dart`
