import '../../constants/app_constants.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_snapshot.dart';

abstract class ProviderImplementation {
  UsageProvider get id;
  bool get supportsLoginFlow => false;

  ProviderMetadata get metadata;

  Future<UsageSnapshot?> fetchUsage(ProviderFetchContext context);
  Future<String?> detectVersion();
}

class ProviderFetchContext {
  final Map<String, String> cookies;
  final String? apiKey;
  final String? bearerToken;

  const ProviderFetchContext({
    this.cookies = const {},
    this.apiKey,
    this.bearerToken,
  });
}
