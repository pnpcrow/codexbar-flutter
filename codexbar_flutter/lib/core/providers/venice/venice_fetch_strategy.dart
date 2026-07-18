import '../shared/generic_api_strategy.dart';
import '../../models/usage_provider.dart';
import '../../models/rate_window.dart';
import '../../models/usage_snapshot.dart';
import '../../models/provider_identity.dart';

/// Venice API fetch strategy using VENICE_API_KEY.
class VeniceFetchStrategy extends GenericAPIStrategy {
  VeniceFetchStrategy()
      : super(
          id: 'venice.api',
          provider: UsageProvider.venice,
          envVarName: 'VENICE_API_KEY',
          apiEndpoint: 'https://api.venice.ai/api/v1/account',
          parseResponse: _parseResponse,
        );

  static UsageSnapshot _parseResponse(Map<String, dynamic> json) {
    RateWindow? primary;

    final data = json['data'] as Map<String, dynamic>?;
    if (data != null) {
      final usage = data['usage'] as Map<String, dynamic>?;
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
    }

    return UsageSnapshot(
      primary: primary,
      updatedAt: DateTime.now(),
      identity: const ProviderIdentitySnapshot(
        providerID: UsageProvider.venice,
        loginMethod: 'api-key',
      ),
    );
  }
}
