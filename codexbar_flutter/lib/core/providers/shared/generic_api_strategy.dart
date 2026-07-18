import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../models/fetch_kind.dart';
import '../../models/fetch_result.dart';
import '../../models/provider_identity.dart';
import '../../models/rate_window.dart';
import '../../models/usage_provider.dart';
import '../../models/usage_snapshot.dart';
import '../fetch_strategy.dart';

/// Generic API fetch strategy for providers that use a simple API key pattern.
class GenericAPIStrategy extends FetchStrategy {
  @override
  final String id;

  @override
  final ProviderFetchKind kind = ProviderFetchKind.apiToken;

  final UsageProvider provider;
  final String envVarName;
  final String apiEndpoint;
  final String Function(String apiKey) buildAuthHeader;
  final UsageSnapshot Function(Map<String, dynamic> json) parseResponse;
  final String sourceLabel;

  GenericAPIStrategy({
    required this.id,
    required this.provider,
    required this.envVarName,
    required this.apiEndpoint,
    this.buildAuthHeader = _defaultAuthHeader,
    required this.parseResponse,
    this.sourceLabel = 'api',
  });

  static String _defaultAuthHeader(String apiKey) => 'Bearer $apiKey';

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async {
    final env = context.env.isEmpty ? Platform.environment : context.env;
    return env[envVarName]?.trim().isNotEmpty == true;
  }

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final env = context.env.isEmpty ? Platform.environment : context.env;
    final apiKey = env[envVarName]?.trim();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('No $envVarName found');
    }

    final response = await http.get(
      Uri.parse(apiEndpoint),
      headers: {
        'Authorization': buildAuthHeader(apiKey),
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 401) {
      throw Exception('Invalid API key for ${provider.displayName}');
    }
    if (response.statusCode != 200) {
      throw Exception('${provider.displayName} API error: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final snapshot = parseResponse(json);

    return ProviderFetchResult(
      usage: snapshot,
      sourceLabel: sourceLabel,
      strategyID: id,
      strategyKind: kind,
    );
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => false;
}

/// Helper to create a simple UsageSnapshot from percent/resets data.
UsageSnapshot makeSimpleSnapshot({
  required UsageProvider provider,
  double? primaryPercent,
  int? primaryWindowMinutes,
  DateTime? primaryResetsAt,
  double? secondaryPercent,
  int? secondaryWindowMinutes,
  DateTime? secondaryResetsAt,
  String? email,
  String? organization,
  String loginMethod = 'api-key',
}) {
  return UsageSnapshot(
    primary: primaryPercent != null
        ? RateWindow(
            usedPercent: primaryPercent,
            windowMinutes: primaryWindowMinutes,
            resetsAt: primaryResetsAt,
          )
        : null,
    secondary: secondaryPercent != null
        ? RateWindow(
            usedPercent: secondaryPercent,
            windowMinutes: secondaryWindowMinutes,
            resetsAt: secondaryResetsAt,
          )
        : null,
    updatedAt: DateTime.now(),
    identity: ProviderIdentitySnapshot(
      providerID: provider,
      accountEmail: email,
      accountOrganization: organization,
      loginMethod: loginMethod,
    ),
  );
}
