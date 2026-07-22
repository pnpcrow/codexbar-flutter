import '../../constants/app_constants.dart';
import '../../models/provider_metadata.dart';
import '../claude/claude_provider.dart';
import '../codex/codex_provider.dart';
import '../gemini/gemini_provider.dart';
import '../cursor/cursor_provider.dart';
import '../openai/openai_provider.dart';
import 'provider_implementation.dart';
import 'generic_providers.dart';

class ProviderDescriptor {
  final UsageProvider id;
  final ProviderMetadata metadata;
  final ProviderImplementation? implementation;

  const ProviderDescriptor({
    required this.id,
    required this.metadata,
    this.implementation,
  });
}

class ProviderDescriptorRegistry {
  static final Map<UsageProvider, ProviderDescriptor> _descriptors = {};
  static bool _initialized = false;

  static void _ensureInitialized() {
    if (_initialized) return;
    _initialized = true;
    _registerDefaults();
  }

  static void _registerDefaults() {
    // Register providers with actual implementations
    register(ClaudeProviderDescriptor.descriptor);
    register(CodexProviderDescriptor.descriptor);
    register(GeminiProviderDescriptor.descriptor);
    register(CursorProviderDescriptor.descriptor);
    register(OpenAIProviderDescriptor.descriptor);

    // Register generic API providers
    for (final descriptor in createGenericProviders()) {
      register(descriptor);
    }

    // Register remaining providers with default metadata
    for (final provider in UsageProvider.values) {
      if (!_descriptors.containsKey(provider)) {
        _descriptors[provider] = ProviderDescriptor(
          id: provider,
          metadata: _defaultMetadata(provider),
        );
      }
    }
  }

  static ProviderMetadata _defaultMetadata(UsageProvider provider) {
    return ProviderMetadata(
      id: provider.name,
      displayName: provider.displayName,
      sessionLabel: 'Session',
      weeklyLabel: 'Weekly',
      toggleTitle: 'Enable ${provider.displayName}',
      cliName: provider.cliName,
      defaultEnabled: _isDefaultEnabled(provider),
      isPrimaryProvider: provider == UsageProvider.codex ||
          provider == UsageProvider.claude,
    );
  }

  static bool _isDefaultEnabled(UsageProvider provider) {
    switch (provider) {
      case UsageProvider.codex:
      case UsageProvider.claude:
      case UsageProvider.cursor:
      case UsageProvider.gemini:
      case UsageProvider.openai:
        return true;
      default:
        return false;
    }
  }

  static ProviderDescriptor descriptorFor(UsageProvider provider) {
    _ensureInitialized();
    return _descriptors[provider]!;
  }

  static Map<UsageProvider, ProviderMetadata> get metadata {
    _ensureInitialized();
    return Map.fromEntries(
      _descriptors.entries.map((e) => MapEntry(e.key, e.value.metadata)),
    );
  }

  static List<ProviderDescriptor> get all {
    _ensureInitialized();
    return _descriptors.values.toList();
  }

  static void register(ProviderDescriptor descriptor) {
    _descriptors[descriptor.id] = descriptor;
  }
}
