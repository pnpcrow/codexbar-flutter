import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'groq_fetch_strategy.dart';

/// Groq provider descriptor.
class GroqDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.groq,
    metadata: const ProviderMetadata(
      id: UsageProvider.groq,
      displayName: 'Groq',
      sessionLabel: 'Usage',
      weeklyLabel: 'Requests',
      supportsOpus: false,
      supportsCredits: false,
      creditsHint: '',
      toggleTitle: 'Show Groq usage',
      cliName: 'groq',
      defaultEnabled: false,
      dashboardURL: 'https://console.groq.com/usage',
      statusPageURL: 'https://status.groq.com',
    ),
    branding: const ProviderBranding(
      iconStyle: 'groq',
      iconResourceName: 'ProviderIcon-groq',
      colorValue: 0xFFF55036, // Groq orange-red
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'groq',
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];

    final api = GroqAPIFetchStrategy();
    if (await api.isAvailable(context)) {
      strategies.add(api);
    }

    return strategies;
  }
}
