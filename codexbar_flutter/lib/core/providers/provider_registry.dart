import '../models/provider_metadata.dart';
import '../models/usage_provider.dart';
import 'provider_descriptor.dart';

/// Registry of all provider descriptors.
/// Direct port of Swift ProviderDescriptorRegistry.
class ProviderRegistry {
  final Map<UsageProvider, ProviderDescriptor> _byID = {};
  final List<ProviderDescriptor> _ordered = [];

  static final ProviderRegistry _instance = ProviderRegistry._();
  factory ProviderRegistry() => _instance;
  ProviderRegistry._();

  void register(ProviderDescriptor descriptor) {
    if (_byID.containsKey(descriptor.id)) return;
    _ordered.add(descriptor);
    _byID[descriptor.id] = descriptor;
  }

  ProviderDescriptor? descriptorFor(UsageProvider id) => _byID[id];

  List<ProviderDescriptor> get all => List.unmodifiable(_ordered);

  Map<UsageProvider, ProviderMetadata> get metadata =>
      {for (final d in _ordered) d.id: d.metadata};

  Map<String, UsageProvider> get cliNameMap {
    final map = <String, UsageProvider>{};
    for (final d in _ordered) {
      map[d.cliName] = d.id;
      for (final alias in d.cliAliases) {
        map[alias] = d.id;
      }
    }
    return map;
  }
}
