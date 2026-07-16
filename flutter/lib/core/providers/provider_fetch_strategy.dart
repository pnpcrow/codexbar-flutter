import 'package:flutter/foundation.dart';

import '../models/usage_provider.dart';

/// The kind of source a [ProviderFetchStrategy] reads from.
///
/// Ported from `ProviderFetchStrategy.Kind` / `ProviderSourceMode` in
/// `ProviderFetchPlan.swift`.
enum FetchStrategyKind {
  cli,
  web,
  oauth,
  apiToken,
  localProbe,
  webDashboard,
}

/// The per-fetch context handed to a strategy. Carries the resolved credential
/// and any user-configured scope (e.g. project ID). Ported conceptually from
/// `ProviderFetchContext` in Swift.
@immutable
class ProviderFetchContext {
  const ProviderFetchContext({
    required this.provider,
    required this.apiKey,
    this.projectID,
    this.extraHeaders = const {},
    this.baseURLOverride,
  });

  final UsageProvider provider;

  /// The resolved API key / admin key / token for this fetch, or `null` when
  /// the strategy is not credential-backed.
  final String? apiKey;
  final String? projectID;
  final Map<String, String> extraHeaders;
  final String? baseURLOverride;
}

/// The outcome of a single strategy fetch attempt.
sealed class ProviderFetchAttempt {
  const ProviderFetchAttempt();
}

/// A successful fetch yielding a snapshot (and optional credits). The optional
/// fields mirror Swift's `ProviderFetchResult`.
final class ProviderFetchSuccess extends ProviderFetchAttempt {
  const ProviderFetchSuccess({
    required this.snapshotJson,
    this.creditsJson,
    this.identityJson,
  });

  /// A JSON map conforming to the [UsageSnapshot.toJson] shape.
  final Map<String, dynamic> snapshotJson;

  /// A JSON map conforming to the [CreditsSnapshot.toJson] shape, if any.
  final Map<String, dynamic>? creditsJson;

  /// A JSON map conforming to [ProviderIdentitySnapshot.toJson], if any.
  final Map<String, dynamic>? identityJson;
}

/// A fetch that failed with a recoverable error; the pipeline may fall back.
final class ProviderFetchFailure extends ProviderFetchAttempt {
  const ProviderFetchFailure(this.error, {this.shouldFallback = true});

  final ProviderFetchError error;
  final bool shouldFallback;
}

/// Categorized fetch errors. Ported from the Swift `ProviderFetchError` family.
sealed class ProviderFetchError {
  const ProviderFetchError(this.message);
  final String message;
}

final class MissingCredentialsError extends ProviderFetchError {
  const MissingCredentialsError([super.message = 'Missing API key or credentials']);
}

final class UnauthorizedError extends ProviderFetchError {
  const UnauthorizedError([super.message = 'Unauthorized — check your API key']);
}

final class ForbiddenError extends ProviderFetchError {
  const ForbiddenError([super.message = 'Forbidden — this key lacks access']);
}

final class NetworkError extends ProviderFetchError {
  const NetworkError(super.message);
}

final class ApiError extends ProviderFetchError {
  const ApiError(super.message);
}

/// A single strategy that knows how to fetch usage for a provider from one
/// source.
///
/// Ported from the `ProviderFetchStrategy` protocol in
/// `Sources/CodexBarCore/Providers/ProviderFetchPlan.swift`.
abstract class ProviderFetchStrategy {
  const ProviderFetchStrategy();

  /// Stable identifier for this strategy (e.g. `openai-api`, `claude-oauth`).
  String get id;

  /// The kind of source this strategy reads from.
  FetchStrategyKind get kind;

  /// Whether this strategy can run given [context] (typically: credential present).
  bool isAvailable(ProviderFetchContext context);

  /// Perform the fetch.
  Future<ProviderFetchAttempt> fetch(ProviderFetchContext context);

  /// Whether the pipeline should fall back to the next strategy after this one
  /// fails with [failure]. Default delegates to the failure's own flag.
  bool shouldFallbackAfter(ProviderFetchFailure failure) => failure.shouldFallback;
}
