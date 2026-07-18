import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'factory_fetch_strategy.dart';

/// Factory (Droid) provider descriptor.
/// Direct port of Swift FactoryProviderDescriptor.
class FactoryDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.factory,
    metadata: const ProviderMetadata(
      id: UsageProvider.factory,
      displayName: 'Factory',
      sessionLabel: 'Usage',
      weeklyLabel: 'Billing',
      supportsOpus: false,
      supportsCredits: true,
      creditsHint: 'Credits',
      toggleTitle: 'Show Factory usage',
      cliName: 'factory',
      defaultEnabled: false,
      dashboardURL: 'https://app.factory.ai/dashboard',
      statusPageURL: 'https://status.factory.ai',
    ),
    branding: const ProviderBranding(
      iconStyle: 'factory',
      iconResourceName: 'ProviderIcon-factory',
      colorValue: 0xFFFF6B35, // RGB(255, 107, 53)
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'factory',
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];

    final web = FactoryWebFetchStrategy();
    if (await web.isAvailable(context)) {
      strategies.add(web);
    }

    return strategies;
  }
}
