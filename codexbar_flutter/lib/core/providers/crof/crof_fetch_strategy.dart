import '../shared/generic_api_strategy.dart';
import '../../models/usage_provider.dart';
import '../../models/rate_window.dart';
import '../../models/usage_snapshot.dart';
import '../../models/provider_identity.dart';

/// Crof API fetch strategy using CROF_API_KEY.
class CrofFetchStrategy extends GenericAPIStrategy {
  CrofFetchStrategy()
      : super(
          id: 'crof.api',
          provider: UsageProvider.crof,
          envVarName: 'CROF_API_KEY',
          apiEndpoint: 'https://api.crof.com/v1/billing/usage',
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
        providerID: UsageProvider.crof,
        loginMethod: 'api-key',
      ),
    );
  }
}
