import 'dart:io';

import '../../debug/debug_logger.dart';
import '../../models/fetch_kind.dart';
import '../../models/fetch_result.dart';
import '../../models/provider_branding.dart';
import '../../models/provider_identity.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../../models/usage_snapshot.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'zai_fetch_strategy.dart';

/// Zai provider descriptor.
/// Supports API token (Z_AI_API_KEY) and web cookie strategies.
class ZaiDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.zai,
    metadata: const ProviderMetadata(
      id: UsageProvider.zai,
      displayName: 'z.ai',
      sessionLabel: 'Tokens',
      weeklyLabel: 'MCP',
      opusLabel: '5-hour',
      supportsOpus: true,
      supportsCredits: false,
      toggleTitle: 'Show z.ai usage',
      cliName: 'zai',
      defaultEnabled: false,
      dashboardURL: 'https://z.ai/manage-apikey/coding-plan/personal/my-plan',
    ),
    branding: const ProviderBranding(
      iconStyle: 'zai',
      iconResourceName: 'ProviderIcon-zai',
      colorValue: 0xFFE85A6A,
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'zai',
    cliAliases: ['z.ai'],
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];
    final env = context.env.isEmpty ? Platform.environment : context.env;

    // 1. API token strategy (Z_AI_API_KEY from env or settings)
    final apiKey = env['Z_AI_API_KEY']?.trim();
    DebugLogger.log('Zai', 'Resolving strategies, API key: ${apiKey != null ? "set (${apiKey.length} chars)" : "not set"}');

    if (apiKey != null && apiKey.isNotEmpty) {
      strategies.add(ZaiAPIFetchStrategy());
      DebugLogger.log('Zai', 'Added API strategy');
    } else {
      DebugLogger.log('Zai', 'No API key found');
      // Add a placeholder strategy that returns a clear message
      strategies.add(_ZaiPlaceholderStrategy());
    }

    return strategies;
  }
}

/// Placeholder strategy when no API key is set.
class _ZaiPlaceholderStrategy extends FetchStrategy {
  @override
  String get id => 'zai.placeholder';

  @override
  ProviderFetchKind get kind => ProviderFetchKind.apiToken;

  @override
  Future<bool> isAvailable(ProviderFetchContext context) async => true;

  @override
  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    return ProviderFetchResult(
      usage: UsageSnapshot(
        updatedAt: DateTime.now(),
        identity: const ProviderIdentitySnapshot(
          providerID: UsageProvider.zai,
          loginMethod: 'Set Z_AI_API_KEY from z.ai/manage-apikey',
        ),
      ),
      sourceLabel: 'no-api-key',
      strategyID: id,
      strategyKind: kind,
    );
  }

  @override
  bool shouldFallback(Object error, ProviderFetchContext context) => false;
}
