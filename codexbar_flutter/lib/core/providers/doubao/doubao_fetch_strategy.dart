import '../shared/generic_api_strategy.dart';
import '../../models/usage_provider.dart';
import '../../models/rate_window.dart';
import '../../models/usage_snapshot.dart';
import '../../models/provider_identity.dart';

/// Doubao API fetch strategy using DOUBAO_API_KEY.
class DoubaoFetchStrategy extends GenericAPIStrategy {
  DoubaoFetchStrategy()
      : super(
          id: 'doubao.api',
          provider: UsageProvider.doubao,
          envVarName: 'DOUBAO_API_KEY',
          apiEndpoint: 'https://ark.cn-beijing.volces.com/api/v3/usage',
          parseResponse: _parseResponse,
        );

  static UsageSnapshot _parseResponse(Map<String, dynamic> json) {
    RateWindow? primary;

    final usage = json['usage'] as Map<String, dynamic>?;
    if (usage != null) {
      final totalTokens = (usage['total_tokens'] as num?)?.toDouble();
      final limitTokens = (usage['limit_tokens'] as num?)?.toDouble();
      if (totalTokens != null && limitTokens != null && limitTokens > 0) {
        final percentUsed = (totalTokens / limitTokens) * 100;
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
        providerID: UsageProvider.doubao,
        loginMethod: 'api-key',
      ),
    );
  }
}
