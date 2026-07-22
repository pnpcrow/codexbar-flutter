import '../../constants/app_constants.dart';
import '../../models/usage_snapshot.dart';
import '../../models/rate_window.dart';
import '../../models/provider_metadata.dart';
import '../../services/http_client.dart';
import '../../services/credential_store.dart';
import '../shared/provider_implementation.dart';
import '../shared/provider_registry.dart';

class CursorProviderDescriptor {
  static ProviderDescriptor get descriptor => ProviderDescriptor(
    id: UsageProvider.cursor,
    metadata: const ProviderMetadata(
      id: 'cursor',
      displayName: 'Cursor',
      sessionLabel: 'Monthly',
      weeklyLabel: 'Daily',
      toggleTitle: 'Enable Cursor',
      cliName: 'cursor',
      defaultEnabled: true,
      dashboardURL: 'https://cursor.sh',
    ),
    implementation: CursorProviderImplementation(),
  );
}

class CursorProviderImplementation extends ProviderImplementation {
  @override
  UsageProvider get id => UsageProvider.cursor;

  @override
  ProviderMetadata get metadata => CursorProviderDescriptor.descriptor.metadata;

  @override
  Future<UsageSnapshot?> fetchUsage(ProviderFetchContext context) async {
    final creds = CredentialStore();
    final cookieHeader = creds.getCookieHeader('cursor');
    if (cookieHeader == null) return null;

    final cookies = <String, String>{};
    for (final part in cookieHeader.split(';')) {
      final eqIndex = part.indexOf('=');
      if (eqIndex > 0) {
        cookies[part.substring(0, eqIndex).trim()] = part.substring(eqIndex + 1).trim();
      }
    }

    final data = await CursorHttpClient.fetchUsage(cookies: cookies);
    if (data != null) return _parseResponse(data);
    return null;
  }

  UsageSnapshot _parseResponse(Map<String, dynamic> data) {
    RateWindow? primary;
    RateWindow? secondary;

    final individual = data['individualUsage'] as Map<String, dynamic>?;
    if (individual != null) {
      final plan = individual['plan'] as Map<String, dynamic>?;
      if (plan != null && plan['enabled'] == true) {
        primary = RateWindow(
          usedPercent: (plan['totalPercentUsed'] as num?)?.toDouble() ?? 0,
        );
      }

      final overall = individual['overall'] as Map<String, dynamic>?;
      if (overall != null && overall['enabled'] == true) {
        secondary = RateWindow(
          usedPercent: (overall['used'] as num?)?.toDouble() != null
              ? ((overall['used'] as num).toDouble() / (overall['limit'] as num).toDouble()) * 100
              : 0,
        );
      }
    }

    // Parse billing cycle for reset time
    DateTime? resetsAt;
    final cycleEnd = data['billingCycleEnd'] as String?;
    if (cycleEnd != null) {
      resetsAt = DateTime.tryParse(cycleEnd);
    }

    return UsageSnapshot(
      primary: primary != null
          ? RateWindow(
              usedPercent: primary.usedPercent,
              windowMinutes: 43200,
              resetsAt: resetsAt,
            )
          : null,
      secondary: secondary,
      updatedAt: DateTime.now(),
      identity: ProviderIdentitySnapshot(
        providerID: UsageProvider.cursor.name,
        loginMethod: 'Cookie',
      ),
    );
  }

  @override
  Future<String?> detectVersion() async => null;
}
