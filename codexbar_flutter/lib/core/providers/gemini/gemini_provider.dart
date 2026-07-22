import 'dart:io';
import '../../constants/app_constants.dart';
import '../../models/usage_snapshot.dart';
import '../../models/rate_window.dart';
import '../../models/provider_metadata.dart';
import '../../services/http_client.dart';
import '../shared/provider_implementation.dart';
import '../shared/provider_registry.dart';

class GeminiProviderDescriptor {
  static ProviderDescriptor get descriptor => ProviderDescriptor(
    id: UsageProvider.gemini,
    metadata: const ProviderMetadata(
      id: 'gemini',
      displayName: 'Gemini',
      sessionLabel: 'Pro',
      weeklyLabel: 'Flash',
      toggleTitle: 'Enable Gemini',
      cliName: 'gemini',
      defaultEnabled: true,
      dashboardURL: 'https://aistudio.google.com',
    ),
    implementation: GeminiProviderImplementation(),
  );
}

class GeminiProviderImplementation extends ProviderImplementation {
  @override
  UsageProvider get id => UsageProvider.gemini;

  @override
  ProviderMetadata get metadata => GeminiProviderDescriptor.descriptor.metadata;

  @override
  Future<UsageSnapshot?> fetchUsage(ProviderFetchContext context) async {
    final data = await GeminiHttpClient.fetchUsage();
    if (data != null) return _parseResponse(data);
    return null;
  }

  UsageSnapshot _parseResponse(Map<String, dynamic> data) {
    RateWindow? primary;
    RateWindow? secondary;

    final buckets = data['buckets'] as List?;
    if (buckets != null && buckets.isNotEmpty) {
      // Group by model and find lowest remaining fraction
      final Map<String, double> modelFractions = {};
      final Map<String, String> modelResetTimes = {};

      for (final bucket in buckets) {
        final b = bucket as Map<String, dynamic>;
        final modelId = b['modelId'] as String? ?? '';
        final fraction = (b['remainingFraction'] as num?)?.toDouble() ?? 1.0;
        final resetTime = b['resetTime'] as String?;

        if (!modelFractions.containsKey(modelId) || fraction < modelFractions[modelId]!) {
          modelFractions[modelId] = fraction;
          if (resetTime != null) modelResetTimes[modelId] = resetTime;
        }
      }

      // Pro model
      final proEntry = modelFractions.entries
          .where((e) => e.key.contains('pro'))
          .firstOrNull;
      if (proEntry != null) {
        primary = RateWindow(
          usedPercent: (1.0 - proEntry.value) * 100,
          resetsAt: modelResetTimes[proEntry.key] != null
              ? DateTime.tryParse(modelResetTimes[proEntry.key]!)
              : null,
        );
      }

      // Flash model
      final flashEntry = modelFractions.entries
          .where((e) => e.key.contains('flash') && !e.key.contains('lite'))
          .firstOrNull;
      if (flashEntry != null) {
        secondary = RateWindow(
          usedPercent: (1.0 - flashEntry.value) * 100,
          resetsAt: modelResetTimes[flashEntry.key] != null
              ? DateTime.tryParse(modelResetTimes[flashEntry.key]!)
              : null,
        );
      }
    }

    return UsageSnapshot(
      primary: primary,
      secondary: secondary,
      updatedAt: DateTime.now(),
      identity: ProviderIdentitySnapshot(
        providerID: UsageProvider.gemini.name,
        loginMethod: 'OAuth',
      ),
    );
  }

  @override
  Future<String?> detectVersion() async {
    try {
      final result = await Process.run('gemini', ['--version']);
      if (result.exitCode == 0) return (result.stdout as String).trim();
    } catch (e) {}
    return null;
  }
}
