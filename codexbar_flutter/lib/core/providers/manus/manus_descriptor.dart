import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'manus_fetch_strategy.dart';

/// Manus provider descriptor.
/// Direct port of Swift ManusProviderDescriptor.
class ManusDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.manus,
    metadata: const ProviderMetadata(
      id: UsageProvider.manus,
      displayName: 'Manus',
      sessionLabel: 'Monthly',
      weeklyLabel: 'Daily',
      supportsOpus: false,
      supportsCredits: true,
      creditsHint: 'Credits',
      toggleTitle: 'Show Manus usage',
      cliName: 'manus',
      defaultEnabled: false,
      dashboardURL: 'https://manus.im/app/settings',
      statusPageURL: 'https://status.manus.im',
    ),
    branding: const ProviderBranding(
      iconStyle: 'manus',
      iconResourceName: 'ProviderIcon-manus',
      colorValue: 0xFF34322D, // RGB(52, 50, 45)
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'manus',
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];

    final web = ManusWebFetchStrategy();
    if (await web.isAvailable(context)) {
      strategies.add(web);
    }

    return strategies;
  }
}
