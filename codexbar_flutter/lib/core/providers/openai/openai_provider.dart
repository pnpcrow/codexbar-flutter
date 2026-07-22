import '../../constants/app_constants.dart';
import '../../models/usage_snapshot.dart';
import '../../models/rate_window.dart';
import '../../models/provider_metadata.dart';
import '../../services/http_client.dart';
import '../../services/credential_store.dart';
import '../shared/provider_implementation.dart';
import '../shared/provider_registry.dart';

class OpenAIProviderDescriptor {
  static ProviderDescriptor get descriptor => ProviderDescriptor(
    id: UsageProvider.openai,
    metadata: const ProviderMetadata(
      id: 'openai',
      displayName: 'OpenAI',
      sessionLabel: 'Usage',
      weeklyLabel: 'Monthly',
      supportsCredits: true,
      creditsHint: 'API credits balance',
      toggleTitle: 'Enable OpenAI',
      cliName: 'openai',
      defaultEnabled: true,
      dashboardURL: 'https://platform.openai.com',
      statusPageURL: 'https://status.openai.com',
    ),
    implementation: OpenAIProviderImplementation(),
  );
}

class OpenAIProviderImplementation extends ProviderImplementation {
  @override
  UsageProvider get id => UsageProvider.openai;

  @override
  ProviderMetadata get metadata => OpenAIProviderDescriptor.descriptor.metadata;

  @override
  Future<UsageSnapshot?> fetchUsage(ProviderFetchContext context) async {
    final creds = CredentialStore();
    final apiKey = context.apiKey ?? creds.getApiKey('openai') ?? creds.getEnvApiKey('openai');
    if (apiKey == null) return null;

    final costsData = await OpenAIHttpClient.fetchUsage(apiKey: apiKey);
    final creditsData = await OpenAIHttpClient.fetchCredits(apiKey: apiKey);
    return _parseResponse(costsData, creditsData);
  }

  UsageSnapshot _parseResponse(
    Map<String, dynamic>? costsData,
    Map<String, dynamic>? creditsData,
  ) {
    RateWindow? primary;
    double? totalCost;

    if (costsData != null && costsData['data'] != null) {
      final data = costsData['data'] as List;
      totalCost = 0;
      for (final bucket in data) {
        final results = bucket['results'] as List? ?? [];
        for (final result in results) {
          final amount = result['amount'] as Map<String, dynamic>?;
          if (amount != null) {
            totalCost = (totalCost ?? 0) + (amount['value'] as num).toDouble();
          }
        }
      }

      primary = RateWindow(
        usedPercent: 0,
        windowMinutes: 43200,
        resetsAt: _nextMonthReset(),
      );
    }

    return UsageSnapshot(
      primary: primary,
      providerCost: totalCost != null
          ? ProviderCostSnapshot(
              totalCost: totalCost,
              currency: 'USD',
            )
          : null,
      updatedAt: DateTime.now(),
      identity: ProviderIdentitySnapshot(
        providerID: UsageProvider.openai.name,
        loginMethod: 'API Key',
      ),
    );
  }

  DateTime _nextMonthReset() {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 1);
  }

  @override
  Future<String?> detectVersion() async => null;
}
