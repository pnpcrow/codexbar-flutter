import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'devin_fetch_strategy.dart';

/// Devin provider descriptor.
/// Direct port of Swift DevinProviderDescriptor.
class DevinDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.devin,
    metadata: const ProviderMetadata(
      id: UsageProvider.devin,
      displayName: 'Devin',
      sessionLabel: 'Daily',
      weeklyLabel: 'Weekly',
      supportsOpus: false,
      supportsCredits: false,
      creditsHint: '',
      toggleTitle: 'Show Devin usage',
      cliName: 'devin',
      defaultEnabled: false,
      dashboardURL: 'https://app.devin.ai/settings/billing',
      statusPageURL: 'https://status.devin.ai',
    ),
    branding: const ProviderBranding(
      iconStyle: 'devin',
      iconResourceName: 'ProviderIcon-devin',
      colorValue: 0xFF46B482, // RGB(70, 180, 130)
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'devin',
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];

    final web = DevinWebFetchStrategy();
    if (await web.isAvailable(context)) {
      strategies.add(web);
    }

    return strategies;
  }
}
