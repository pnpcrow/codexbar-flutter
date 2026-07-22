import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../constants/app_constants.dart';
import '../../models/usage_snapshot.dart';
import '../../models/provider_metadata.dart';
import '../../services/credential_store.dart';
import 'provider_implementation.dart';
import 'provider_registry.dart';

class GenericApiProvider extends ProviderImplementation {
  @override
  final UsageProvider id;
  final String displayName;
  final String? envKey;
  final String? usageUrl;
  final UsageSnapshot Function(Map<String, dynamic>)? parser;

  GenericApiProvider({
    required this.id,
    required this.displayName,
    this.envKey,
    this.usageUrl,
    this.parser,
  });

  @override
  ProviderMetadata get metadata => ProviderMetadata(
    id: id.name,
    displayName: displayName,
    sessionLabel: 'Usage',
    weeklyLabel: 'Weekly',
    toggleTitle: 'Enable $displayName',
    cliName: id.cliName,
  );

  @override
  Future<UsageSnapshot?> fetchUsage(ProviderFetchContext context) async {
    final creds = CredentialStore();
    final apiKey = context.apiKey ?? creds.getApiKey(id.name) ?? (envKey != null ? Platform.environment[envKey!] : null);
    if (apiKey == null || usageUrl == null) return null;

    try {
      final response = await http.get(
        Uri.parse(usageUrl!),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Accept': 'application/json',
          'User-Agent': 'CodexBar/0.1.0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (parser != null) return parser!(data);
        return _defaultParse(data);
      }
    } catch (e) {}
    return null;
  }

  UsageSnapshot _defaultParse(Map<String, dynamic> data) {
    return UsageSnapshot(
      updatedAt: DateTime.now(),
      identity: ProviderIdentitySnapshot(
        providerID: id.name,
        loginMethod: 'API Key',
      ),
    );
  }

  @override
  Future<String?> detectVersion() async => null;
}

// Provider definitions using generic base
List<ProviderDescriptor> createGenericProviders() {
  return [
    ProviderDescriptor(
      id: UsageProvider.groq,
      metadata: const ProviderMetadata(
        id: 'groq', displayName: 'Groq', sessionLabel: 'Usage', weeklyLabel: 'Weekly',
        toggleTitle: 'Enable Groq', cliName: 'groq', statusPageURL: 'https://status.groq.com',
      ),
      implementation: GenericApiProvider(
        id: UsageProvider.groq, displayName: 'Groq',
        envKey: 'GROQ_API_KEY',
        usageUrl: 'https://api.groq.com/openai/v1/usage',
      ),
    ),
    ProviderDescriptor(
      id: UsageProvider.mistral,
      metadata: const ProviderMetadata(
        id: 'mistral', displayName: 'Mistral', sessionLabel: 'Usage', weeklyLabel: 'Weekly',
        supportsCredits: true, toggleTitle: 'Enable Mistral', cliName: 'mistral',
      ),
      implementation: GenericApiProvider(
        id: UsageProvider.mistral, displayName: 'Mistral',
        envKey: 'MISTRAL_API_KEY',
      ),
    ),
    ProviderDescriptor(
      id: UsageProvider.deepseek,
      metadata: const ProviderMetadata(
        id: 'deepseek', displayName: 'DeepSeek', sessionLabel: 'Usage', weeklyLabel: 'Weekly',
        supportsCredits: true, toggleTitle: 'Enable DeepSeek', cliName: 'deepseek',
      ),
      implementation: GenericApiProvider(
        id: UsageProvider.deepseek, displayName: 'DeepSeek',
        envKey: 'DEEPSEEK_API_KEY',
      ),
    ),
    ProviderDescriptor(
      id: UsageProvider.perplexity,
      metadata: const ProviderMetadata(
        id: 'perplexity', displayName: 'Perplexity', sessionLabel: 'Usage', weeklyLabel: 'Weekly',
        supportsCredits: true, toggleTitle: 'Enable Perplexity', cliName: 'perplexity',
      ),
      implementation: GenericApiProvider(
        id: UsageProvider.perplexity, displayName: 'Perplexity',
        envKey: 'PERPLEXITY_API_KEY',
      ),
    ),
    ProviderDescriptor(
      id: UsageProvider.elevenlabs,
      metadata: const ProviderMetadata(
        id: 'elevenlabs', displayName: 'ElevenLabs', sessionLabel: 'Characters', weeklyLabel: 'Weekly',
        supportsCredits: true, toggleTitle: 'Enable ElevenLabs', cliName: 'elevenlabs',
      ),
      implementation: GenericApiProvider(
        id: UsageProvider.elevenlabs, displayName: 'ElevenLabs',
        envKey: 'ELEVENLABS_API_KEY',
      ),
    ),
    ProviderDescriptor(
      id: UsageProvider.openrouter,
      metadata: const ProviderMetadata(
        id: 'openrouter', displayName: 'OpenRouter', sessionLabel: 'Usage', weeklyLabel: 'Weekly',
        supportsCredits: true, toggleTitle: 'Enable OpenRouter', cliName: 'openrouter',
      ),
      implementation: GenericApiProvider(
        id: UsageProvider.openrouter, displayName: 'OpenRouter',
        envKey: 'OPENROUTER_API_KEY',
      ),
    ),
    ProviderDescriptor(
      id: UsageProvider.warp,
      metadata: const ProviderMetadata(
        id: 'warp', displayName: 'Warp', sessionLabel: 'Requests', weeklyLabel: 'Monthly',
        supportsCredits: true, toggleTitle: 'Enable Warp', cliName: 'warp',
      ),
      implementation: GenericApiProvider(
        id: UsageProvider.warp, displayName: 'Warp',
        envKey: 'WARP_API_KEY',
      ),
    ),
    ProviderDescriptor(
      id: UsageProvider.moonshot,
      metadata: const ProviderMetadata(
        id: 'moonshot', displayName: 'Moonshot', sessionLabel: 'Balance', weeklyLabel: 'Monthly',
        supportsCredits: true, toggleTitle: 'Enable Moonshot', cliName: 'moonshot',
      ),
      implementation: GenericApiProvider(
        id: UsageProvider.moonshot, displayName: 'Moonshot',
        envKey: 'MOONSHOT_API_KEY',
      ),
    ),
    ProviderDescriptor(
      id: UsageProvider.venice,
      metadata: const ProviderMetadata(
        id: 'venice', displayName: 'Venice', sessionLabel: 'Balance', weeklyLabel: 'Monthly',
        supportsCredits: true, toggleTitle: 'Enable Venice', cliName: 'venice',
      ),
      implementation: GenericApiProvider(
        id: UsageProvider.venice, displayName: 'Venice',
        envKey: 'VENICE_API_KEY',
      ),
    ),
    ProviderDescriptor(
      id: UsageProvider.deepgram,
      metadata: const ProviderMetadata(
        id: 'deepgram', displayName: 'Deepgram', sessionLabel: 'Usage', weeklyLabel: 'Monthly',
        toggleTitle: 'Enable Deepgram', cliName: 'deepgram',
      ),
      implementation: GenericApiProvider(
        id: UsageProvider.deepgram, displayName: 'Deepgram',
        envKey: 'DEEPGRAM_API_KEY',
      ),
    ),
    ProviderDescriptor(
      id: UsageProvider.poe,
      metadata: const ProviderMetadata(
        id: 'poe', displayName: 'Poe', sessionLabel: 'Points', weeklyLabel: 'Weekly',
        supportsCredits: true, toggleTitle: 'Enable Poe', cliName: 'poe',
      ),
      implementation: GenericApiProvider(
        id: UsageProvider.poe, displayName: 'Poe',
        envKey: 'POE_API_KEY',
      ),
    ),
  ];
}
