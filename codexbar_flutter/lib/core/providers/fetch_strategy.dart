import '../models/fetch_kind.dart';
import '../models/fetch_result.dart';

/// Context for provider fetch operations.
/// Direct port of Swift ProviderFetchContext.
class ProviderFetchContext {
  final ProviderSourceMode sourceMode;
  final bool includeCredits;
  final bool includeOptionalUsage;
  final Duration webTimeout;
  final bool verbose;
  final Map<String, String> env;
  final Duration? costUsageHistoryDays;

  const ProviderFetchContext({
    this.sourceMode = ProviderSourceMode.auto,
    this.includeCredits = false,
    this.includeOptionalUsage = true,
    this.webTimeout = const Duration(seconds: 30),
    this.verbose = false,
    this.env = const {},
    this.costUsageHistoryDays,
  });
}

/// Provider source mode - determines how data is fetched.
enum ProviderSourceMode {
  auto,
  web,
  cli,
  oauth,
  api;

  bool get usesWeb => this == auto || this == web;
}

/// Abstract fetch strategy - each provider implements one or more of these.
/// Direct port of Swift ProviderFetchStrategy protocol.
abstract class FetchStrategy {
  String get id;
  ProviderFetchKind get kind;

  Future<bool> isAvailable(ProviderFetchContext context);
  Future<ProviderFetchResult> fetch(ProviderFetchContext context);
  bool shouldFallback(Object error, ProviderFetchContext context);
}

/// Fetch pipeline - tries strategies in order, falling back on failure.
/// Direct port of Swift ProviderFetchPipeline.
class FetchPipeline {
  final Future<List<FetchStrategy>> Function(ProviderFetchContext) resolveStrategies;

  const FetchPipeline({required this.resolveStrategies});

  Future<ProviderFetchOutcome> fetch({
    required ProviderFetchContext context,
    required String providerName,
  }) async {
    final strategies = await resolveStrategies(context);
    final attempts = <ProviderFetchAttempt>[];
    Object? lastError;

    for (final strategy in strategies) {
      final available = await strategy.isAvailable(context);
      if (!available) {
        attempts.add(ProviderFetchAttempt(
          strategyID: strategy.id,
          kind: strategy.kind,
          wasAvailable: false,
        ));
        continue;
      }

      try {
        final result = await strategy.fetch(context);
        attempts.add(ProviderFetchAttempt(
          strategyID: strategy.id,
          kind: strategy.kind,
          wasAvailable: true,
        ));
        return ProviderFetchOutcome.success(result, attempts);
      } catch (e) {
        lastError = e;
        attempts.add(ProviderFetchAttempt(
          strategyID: strategy.id,
          kind: strategy.kind,
          wasAvailable: true,
          errorDescription: e.toString(),
        ));
        if (!strategy.shouldFallback(e, context)) {
          return ProviderFetchOutcome.failure(e, attempts);
        }
      }
    }

    final error = lastError ?? ProviderFetchError('No available fetch strategy for $providerName');
    return ProviderFetchOutcome.failure(error, attempts);
  }
}
