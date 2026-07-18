import '../models/fetch_result.dart';
import '../models/usage_provider.dart';
import '../providers/fetch_strategy.dart';

/// Race strategy for token resolution.
/// When both CLI and browser cookie are available, races them and uses the faster one.
/// Falls back to the other on failure.
/// Direct port of Swift ProviderFetchPipeline + ProviderCandidateRetryRunner.
class TokenRaceStrategy {
  /// Race fetch between CLI and cookie strategies.
  /// Returns the result from whichever strategy succeeds first.
  Future<ProviderFetchResult> raceFetch({
    required FetchStrategy cliStrategy,
    required FetchStrategy cookieStrategy,
    required ProviderFetchContext context,
  }) async {
    final cliAvailable = await cliStrategy.isAvailable(context);
    final cookieAvailable = await cookieStrategy.isAvailable(context);

    if (cliAvailable && cookieAvailable) {
      // Race: use whichever responds first
      try {
        return await Future.any([
          cliStrategy.fetch(context),
          cookieStrategy.fetch(context),
        ]);
      } catch (e) {
        // Both failed - try the other one explicitly
        try {
          return await cliStrategy.fetch(context);
        } catch (_) {
          return await cookieStrategy.fetch(context);
        }
      }
    } else if (cliAvailable) {
      return await cliStrategy.fetch(context);
    } else if (cookieAvailable) {
      return await cookieStrategy.fetch(context);
    }

    throw ProviderFetchError('No authentication method available');
  }

  /// Get available strategies for a provider, ordered by priority.
  Future<List<FetchStrategy>> resolveAvailableStrategies({
    required UsageProvider provider,
    required ProviderFetchContext context,
    required FetchStrategy? Function(UsageProvider, ProviderFetchContext) cliFactory,
    required FetchStrategy? Function(UsageProvider, ProviderFetchContext) cookieFactory,
  }) async {
    final strategies = <FetchStrategy>[];

    // CLI first (faster, more reliable)
    final cli = cliFactory(provider, context);
    if (cli != null && await cli.isAvailable(context)) {
      strategies.add(cli);
    }

    // Cookie as fallback
    final cookie = cookieFactory(provider, context);
    if (cookie != null && await cookie.isAvailable(context)) {
      strategies.add(cookie);
    }

    return strategies;
  }
}
