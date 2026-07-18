import '../shared/generic_api_strategy.dart';
import '../../models/usage_provider.dart';
import '../../models/rate_window.dart';
import '../../models/usage_snapshot.dart';
import '../../models/provider_identity.dart';

/// Poe API fetch strategy using POE_API_KEY.
class PoeFetchStrategy extends GenericAPIStrategy {
  PoeFetchStrategy()
      : super(
          id: 'poe.api',
          provider: UsageProvider.poe,
          envVarName: 'POE_API_KEY',
          apiEndpoint: 'https://api.poe.com/bot/usage',
          parseResponse: _parseResponse,
        );

  static UsageSnapshot _parseResponse(Map<String, dynamic> json) {
    RateWindow? primary;

    final usage = json['usage'] as Map<String, dynamic>?;
    if (usage != null) {
      final pointsUsed = (usage['points_used'] as num?)?.toDouble();
      final pointsLimit = (usage['points_limit'] as num?)?.toDouble();
      if (pointsUsed != null && pointsLimit != null && pointsLimit > 0) {
        final percentUsed = (pointsUsed / pointsLimit) * 100;
        primary = RateWindow(
          usedPercent: percentUsed.clamp(0.0, 100.0),
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
        providerID: UsageProvider.poe,
        loginMethod: 'api-key',
      ),
    );
  }
}
