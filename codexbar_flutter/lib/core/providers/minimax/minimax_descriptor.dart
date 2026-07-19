import 'dart:io';

import '../../debug/debug_logger.dart';
import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'minimax_fetch_strategy.dart';

/// MiniMax provider descriptor.
/// Supports API token and web cookie strategies.
class MiniMaxDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.minimax,
    metadata: const ProviderMetadata(
      id: UsageProvider.minimax,
      displayName: 'MiniMax',
      sessionLabel: 'Prompts',
      weeklyLabel: 'Window',
      supportsOpus: false,
      supportsCredits: false,
      toggleTitle: 'Show MiniMax usage',
      cliName: 'minimax',
      defaultEnabled: false,
      dashboardURL: 'https://platform.minimax.io/user-center/payment/coding-plan?cycle_type=3',
    ),
    branding: const ProviderBranding(
      iconStyle: 'minimax',
      iconResourceName: 'ProviderIcon-minimax',
      colorValue: 0xFFFE603C,
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'minimax',
    cliAliases: ['mini-max'],
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];
    final env = context.env.isEmpty ? Platform.environment : context.env;

    // 1. API token strategy
    final apiToken = env['MINIMAX_API_TOKEN']?.trim();
    DebugLogger.log('MiniMax', 'Resolving strategies, API token: ${apiToken != null ? "set" : "not set"}');
    if (apiToken != null && apiToken.isNotEmpty) {
      strategies.add(MiniMaxAPIFetchStrategy());
      DebugLogger.log('MiniMax', 'Added API strategy');
    }

    // 2. Web cookie strategy
    strategies.add(MiniMaxWebFetchStrategy());
    DebugLogger.log('MiniMax', 'Added Web strategy, total strategies: ${strategies.length}');

    return strategies;
  }
}
