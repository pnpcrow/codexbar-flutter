import 'dart:math' as math;

/// Loading animation patterns driving the icon meter fill during a refresh.
///
/// Ported from `Sources/CodexBar/LoadingPattern.swift`. Each pattern defines
/// a [value] in 0–100 from a phase (radians) and a [secondaryOffset] so the
/// lower bar animates differently.
enum LoadingPattern {
  knightRider,
  cylon,
  outsideIn,
  race,
  pulse,
  unbraid;

  String get displayName => switch (this) {
        LoadingPattern.knightRider => 'Knight Rider',
        LoadingPattern.cylon => 'Cylon',
        LoadingPattern.outsideIn => 'Outside-In',
        LoadingPattern.race => 'Race',
        LoadingPattern.pulse => 'Pulse',
        LoadingPattern.unbraid => 'Unbraid (logo → bars)',
      };

  /// Secondary offset so the lower bar moves differently.
  double get secondaryOffset => switch (this) {
        LoadingPattern.knightRider => math.pi,
        LoadingPattern.cylon => math.pi / 2,
        LoadingPattern.outsideIn => math.pi,
        LoadingPattern.race => math.pi / 3,
        LoadingPattern.pulse => math.pi / 2,
        LoadingPattern.unbraid => math.pi / 2,
      };

  /// Progress value (0–100) for the given [phase] in radians.
  double value(double phase) {
    final v = switch (this) {
      LoadingPattern.knightRider => 0.5 + 0.5 * math.sin(phase), // ping-pong
      LoadingPattern.cylon =>
        (phase % (math.pi * 2)) / (math.pi * 2), // sawtooth 0→1
      LoadingPattern.outsideIn => math.cos(phase).abs(), // high at edges
      LoadingPattern.race =>
        ((phase * 1.2) % (math.pi * 2)) / (math.pi * 2),
      LoadingPattern.pulse => 0.4 + 0.6 * (0.5 + 0.5 * math.sin(phase)), // 40–100%
      LoadingPattern.unbraid => 0.5 + 0.5 * math.sin(phase), // smooth 0→1
    };
    return (v * 100).clamp(0, 100).toDouble();
  }
}
