import '../shared/generic_api_strategy.dart';
import '../../models/usage_provider.dart';
import '../../models/rate_window.dart';
import '../../models/usage_snapshot.dart';
import '../../models/provider_identity.dart';

/// Warp API fetch strategy using WARP_API_KEY.
class WarpFetchStrategy extends GenericAPIStrategy {
  WarpFetchStrategy()
      : super(
          id: 'warp.api',
          provider: UsageProvider.warp,
          envVarName: 'WARP_API_KEY',
          apiEndpoint: 'https://api.warp.dev/v1/usage',
          parseResponse: _parseResponse,
        );

  static UsageSnapshot _parseResponse(Map<String, dynamic> json) {
    RateWindow? primary;

    final usage = json['usage'] as Map<String, dynamic>?;
    if (usage != null) {
      final percentUsed = (usage['percent_used'] as num?)?.toDouble();
      if (percentUsed != null) {
        primary = RateWindow(
          usedPercent: percentUsed,
          windowMinutes: usage['window_minutes'] as int?,
          resetsAt: usage['resets_at'] != null
              ? DateTime.parse(usage['resets_at'] as String)
              : null,
        );
      }
    }

    return UsageSnapshot(
      primary: primary,
      updatedAt: DateTime.now(),
      identity: const ProviderIdentitySnapshot(
        providerID: UsageProvider.warp,
        loginMethod: 'api-key',
      ),
    );
  }
}
