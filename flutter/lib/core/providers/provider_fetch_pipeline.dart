import 'package:flutter/foundation.dart';

import 'provider_fetch_strategy.dart';

/// An ordered set of strategies tried in sequence until one succeeds.
///
/// Ported from `ProviderFetchPipeline` in `ProviderFetchPlan.swift`.
@immutable
class ProviderFetchPipeline {
  const ProviderFetchPipeline(this.strategies);

  final List<ProviderFetchStrategy> strategies;

  /// Run the pipeline. Returns the first successful attempt, or the last
  /// failure if every strategy fails or is unavailable.
  ///
  /// Ported from `ProviderFetchPipeline.fetch`. Strategies whose
  /// [ProviderFetchStrategy.isAvailable] returns false are skipped; failures
  /// fall through to the next strategy unless `shouldFallbackAfter` is false.
  Future<ProviderFetchAttempt> fetch(ProviderFetchContext context) async {
    ProviderFetchAttempt? lastFailure;
    var attemptedAny = false;

    for (final strategy in strategies) {
      if (!strategy.isAvailable(context)) continue;
      attemptedAny = true;
      final attempt = await strategy.fetch(context);
      if (attempt is ProviderFetchSuccess) return attempt;
      if (attempt is ProviderFetchFailure) {
        lastFailure = attempt;
        if (!strategy.shouldFallbackAfter(attempt)) return attempt;
      }
    }

    if (!attemptedAny) {
      return ProviderFetchFailure(const MissingCredentialsError());
    }
    return lastFailure ??
        ProviderFetchFailure(const ApiError('No fetch strategy produced a result'));
  }
}
