import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'cursor_fetch_strategy.dart';

/// Cursor provider descriptor.
/// Direct port of Swift CursorProviderDescriptor.
class CursorDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.cursor,
    metadata: const ProviderMetadata(
      id: UsageProvider.cursor,
      displayName: 'Cursor',
      sessionLabel: 'Session',
      weeklyLabel: 'Monthly',
      supportsOpus: false,
      supportsCredits: false,
      creditsHint: '',
      toggleTitle: 'Show Cursor usage',
      cliName: 'cursor',
      defaultEnabled: false,
      dashboardURL: 'https://cursor.com/dashboard',
      statusPageURL: 'https://status.cursor.com',
    ),
    branding: const ProviderBranding(
      iconStyle: 'cursor',
      iconResourceName: 'ProviderIcon-cursor',
      colorValue: 0xFF00BFA5, // RGB(0, 191, 165)
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'cursor',
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];

    final web = CursorWebFetchStrategy();
    if (await web.isAvailable(context)) {
      strategies.add(web);
    }

    return strategies;
  }
}
