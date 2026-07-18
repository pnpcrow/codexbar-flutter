import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'qoder_fetch_strategy.dart';

/// Qoder provider descriptor.
/// Direct port of Swift QoderProviderDescriptor.
class QoderDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.qoder,
    metadata: const ProviderMetadata(
      id: UsageProvider.qoder,
      displayName: 'Qoder',
      sessionLabel: 'Usage',
      weeklyLabel: 'Credits',
      supportsOpus: false,
      supportsCredits: true,
      creditsHint: 'Credits',
      toggleTitle: 'Show Qoder usage',
      cliName: 'qoder',
      defaultEnabled: false,
      dashboardURL: 'https://qoder.com/dashboard',
      statusPageURL: 'https://status.qoder.com',
    ),
    branding: const ProviderBranding(
      iconStyle: 'qoder',
      iconResourceName: 'ProviderIcon-qoder',
      colorValue: 0xFF10B981, // RGB(16, 185, 129)
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'qoder',
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];

    final web = QoderWebFetchStrategy();
    if (await web.isAvailable(context)) {
      strategies.add(web);
    }

    return strategies;
  }
}
