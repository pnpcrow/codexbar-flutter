import 'package:flutter/foundation.dart';

/// Canonical adaptive-refresh decision table shared by the app and (in Swift)
/// the offline replay tooling.
///
/// Pure Dart port of `Sources/AdaptiveRefreshCore/AdaptiveRefreshPolicyCore.swift`.
/// Thresholds and delays live here only; platform adapters normalize their
/// thermal/power signals before calling [nextDelay].
@immutable
class AdaptiveRefreshPolicyCore {
  const AdaptiveRefreshPolicyCore();

  static const Duration _recentInteractionThreshold = Duration(minutes: 5);
  static const Duration _warmThreshold = Duration(minutes: 60);
  static const Duration _idleThreshold = Duration(minutes: 240);

  static const Duration _recentInteractionDelay = Duration(minutes: 2);
  static const Duration _warmDelay = Duration(minutes: 5);
  static const Duration _idleDelay = Duration(minutes: 15);
  static const Duration _longIdleDelay = Duration(minutes: 30);
  static const Duration _constrainedDelay = Duration(minutes: 30);

  /// Representative cadence for consumers that need one interval but cannot
  /// access live state. Mirrors `nominalIntervalForHeuristics` (5 minutes).
  static const Duration nominalIntervalForHeuristics = Duration(minutes: 5);

  AdaptiveRefreshDecision nextDelay(AdaptiveRefreshInput input) {
    if (input.lowPowerModeEnabled || input.thermalPressure == ThermalPressure.constrained) {
      return const AdaptiveRefreshDecision(
        delay: _constrainedDelay,
        reason: AdaptiveRefreshReason.constrained,
      );
    }

    final lastMenuOpenAt = input.lastMenuOpenAt;
    if (lastMenuOpenAt == null) {
      return const AdaptiveRefreshDecision(
        delay: _longIdleDelay,
        reason: AdaptiveRefreshReason.longIdle,
      );
    }

    // A future or clock-adjusted timestamp yields a negative age, which reads
    // as recent — matching the Swift `timeIntervalSince` behavior.
    final age = input.now.difference(lastMenuOpenAt);

    if (age <= _recentInteractionThreshold) {
      return const AdaptiveRefreshDecision(
        delay: _recentInteractionDelay,
        reason: AdaptiveRefreshReason.recentInteraction,
      );
    }
    if (age <= _warmThreshold) {
      return const AdaptiveRefreshDecision(
        delay: _warmDelay,
        reason: AdaptiveRefreshReason.warm,
      );
    }
    if (age < _idleThreshold) {
      return const AdaptiveRefreshDecision(
        delay: _idleDelay,
        reason: AdaptiveRefreshReason.idle,
      );
    }
    return const AdaptiveRefreshDecision(
      delay: _longIdleDelay,
      reason: AdaptiveRefreshReason.longIdle,
    );
  }
}

enum ThermalPressure { nominal, constrained }

enum AdaptiveRefreshReason {
  recentInteraction,
  warm,
  idle,
  longIdle,
  constrained,
}

@immutable
class AdaptiveRefreshInput {
  const AdaptiveRefreshInput({
    required this.now,
    required this.lastMenuOpenAt,
    required this.lowPowerModeEnabled,
    required this.thermalPressure,
  });

  final DateTime now;
  final DateTime? lastMenuOpenAt;
  final bool lowPowerModeEnabled;
  final ThermalPressure thermalPressure;
}

@immutable
class AdaptiveRefreshDecision {
  const AdaptiveRefreshDecision({required this.delay, required this.reason});

  final Duration delay;
  final AdaptiveRefreshReason reason;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdaptiveRefreshDecision &&
          other.delay == delay &&
          other.reason == reason;

  @override
  int get hashCode => Object.hash(delay, reason);
}
