import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:codexbar/ui/tray/loading_pattern.dart';

void main() {
  group('LoadingPattern', () {
    test('knightRider is symmetric around 0.5 at 0 and π', () {
      // 0.5 + 0.5*sin(0) = 0.5 → 50%.
      expect(LoadingPattern.knightRider.value(0), closeTo(50, 0.001));
      // 0.5 + 0.5*sin(π) ≈ 0.5 → 50%.
      expect(LoadingPattern.knightRider.value(math.pi), closeTo(50, 0.001));
      // Peak at π/2 → 100%.
      expect(LoadingPattern.knightRider.value(math.pi / 2), closeTo(100, 0.001));
    });

    test('pulse stays within 40–100%', () {
      for (var p = 0.0; p < math.pi * 4; p += 0.3) {
        final v = LoadingPattern.pulse.value(p);
        expect(v, greaterThanOrEqualTo(40));
        expect(v, lessThanOrEqualTo(100));
      }
    });

    test('all values are clamped to 0–100', () {
      for (final pattern in LoadingPattern.values) {
        for (var p = 0.0; p < math.pi * 8; p += 0.5) {
          final v = pattern.value(p);
          expect(v, greaterThanOrEqualTo(0));
          expect(v, lessThanOrEqualTo(100));
        }
      }
    });

    test('every pattern has a non-null secondary offset', () {
      for (final pattern in LoadingPattern.values) {
        expect(pattern.secondaryOffset, isNonNegative);
      }
    });
  });
}
