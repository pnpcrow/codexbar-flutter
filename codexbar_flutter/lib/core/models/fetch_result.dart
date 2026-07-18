import 'fetch_kind.dart';
import 'usage_snapshot.dart';

/// Result of a provider fetch operation.
/// Direct port of Swift ProviderFetchResult.
class ProviderFetchResult {
  final UsageSnapshot usage;
  final String sourceLabel;
  final String strategyID;
  final ProviderFetchKind strategyKind;

  const ProviderFetchResult({
    required this.usage,
    required this.sourceLabel,
    required this.strategyID,
    required this.strategyKind,
  });
}

/// Attempt to fetch using a strategy.
class ProviderFetchAttempt {
  final String strategyID;
  final ProviderFetchKind kind;
  final bool wasAvailable;
  final String? errorDescription;

  const ProviderFetchAttempt({
    required this.strategyID,
    required this.kind,
    required this.wasAvailable,
    this.errorDescription,
  });
}

/// Outcome of the fetch pipeline.
class ProviderFetchOutcome {
  final ProviderFetchResult? result;
  final Object? error;
  final List<ProviderFetchAttempt> attempts;

  const ProviderFetchOutcome({
    this.result,
    this.error,
    this.attempts = const [],
  });

  bool get isSuccess => result != null;

  factory ProviderFetchOutcome.success(ProviderFetchResult result,
          [List<ProviderFetchAttempt> attempts = const []]) =>
      ProviderFetchOutcome(result: result, attempts: attempts);

  factory ProviderFetchOutcome.failure(Object error,
          [List<ProviderFetchAttempt> attempts = const []]) =>
      ProviderFetchOutcome(error: error, attempts: attempts);
}

/// Error when no fetch strategy is available.
class ProviderFetchError implements Exception {
  final String message;
  const ProviderFetchError(this.message);

  @override
  String toString() => 'ProviderFetchError: $message';
}
