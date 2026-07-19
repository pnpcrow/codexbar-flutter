import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../debug/debug_logger.dart';
import '../../models/fetch_kind.dart';
import '../../models/fetch_result.dart';
import '../../models/provider_identity.dart';
import '../../models/rate_window.dart';
import '../../models/usage_provider.dart';
import '../../models/usage_snapshot.dart';
import '../fetch_strategy.dart';

/// Antigravity local probe strategy - checks running Antigravity processes.
/// Direct port of Swift AntigravityStatusFetchStrategy.
class AntigravityLocalFetchStrategy extends FetchStrategy {
  @override
  String get id => 'antigravity.local';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.localProbe;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    // Always available - will try to probe in fetch()
    return true;
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    // Try to find running Antigravity process
    // Check common ports for Antigravity's local server
    final ports = [9222, 9223, 9224, 8080, 8081];

    for (final port in ports) {
      try {
        final response = await http
            .get(Uri.parse('http://localhost:$port/status'))
            .timeout(const Duration(seconds: 2));

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          return _parseResponse(json, 'local:$port');
        }
      } catch (_) {
        // Port not listening, try next
      }
    }

    throw Exception('No Antigravity process found');
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => true;

  ProviderFetchResult _parseResponse(Map<String, dynamic> json, String source) {
    // Parse Antigravity status response
    double? percent;
    String? accountEmail;

    final usage = json['usage'] ?? json['quota'];
    if (usage is Map) {
      final used = (usage['used'] as num?)?.toDouble() ?? 0;
      final total = (usage['total'] as num?)?.toDouble() ?? 1;
      percent = (used / total * 100).clamp(0, 100);
    }

    accountEmail = json['email'] as String?;

    return ProviderFetchResult(
      usage: UsageSnapshot(
        primary: percent != null ? RateWindow(usedPercent: percent) : null,
        updatedAt: DateTime.now(),
        identity: ProviderIdentitySnapshot(
          providerID: UsageProvider.antigravity,
          accountEmail: accountEmail,
          loginMethod: 'local',
        ),
      ),
      sourceLabel: source,
      strategyID: id,
      strategyKind: kind,
    );
  }
}

/// Antigravity CLI fetch strategy - uses agy binary.
class AntigravityCLIFetchStrategy extends FetchStrategy {
  @override
  String get id => 'antigravity.cli';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.cli;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    try {
      final result = await Process.run('which', ['agy']);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    // TODO: Implement agy CLI fetch
    throw Exception('Antigravity CLI fetch not yet implemented');
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => true;
}
