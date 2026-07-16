import 'package:flutter_test/flutter_test.dart';

import 'package:codexbar/core/refresh/adaptive_refresh_policy.dart';

void main() {
  const policy = AdaptiveRefreshPolicyCore();
  // Fixed reference "now" so thresholds are deterministic.
  final now = DateTime.utc(2026, 7, 16, 12);

  group('AdaptiveRefreshPolicyCore.nextDelay', () {
    test('long idle when menu was never opened', () {
      final d = policy.nextDelay(AdaptiveRefreshInput(
        now: now,
        lastMenuOpenAt: null,
        lowPowerModeEnabled: false,
        thermalPressure: ThermalPressure.nominal,
      ));
      expect(d.reason, AdaptiveRefreshReason.longIdle);
      expect(d.delay, const Duration(minutes: 30));
    });

    test('recent interaction within 5 minutes', () {
      final d = policy.nextDelay(AdaptiveRefreshInput(
        now: now,
        lastMenuOpenAt: now.subtract(const Duration(minutes: 2)),
        lowPowerModeEnabled: false,
        thermalPressure: ThermalPressure.nominal,
      ));
      expect(d.reason, AdaptiveRefreshReason.recentInteraction);
      expect(d.delay, const Duration(minutes: 2));
    });

    test('warm within 1 hour', () {
      final d = policy.nextDelay(AdaptiveRefreshInput(
        now: now,
        lastMenuOpenAt: now.subtract(const Duration(minutes: 30)),
        lowPowerModeEnabled: false,
        thermalPressure: ThermalPressure.nominal,
      ));
      expect(d.reason, AdaptiveRefreshReason.warm);
      expect(d.delay, const Duration(minutes: 5));
    });

    test('idle within 4 hours', () {
      final d = policy.nextDelay(AdaptiveRefreshInput(
        now: now,
        lastMenuOpenAt: now.subtract(const Duration(hours: 2)),
        lowPowerModeEnabled: false,
        thermalPressure: ThermalPressure.nominal,
      ));
      expect(d.reason, AdaptiveRefreshReason.idle);
      expect(d.delay, const Duration(minutes: 15));
    });

    test('long idle after 4 hours', () {
      final d = policy.nextDelay(AdaptiveRefreshInput(
        now: now,
        lastMenuOpenAt: now.subtract(const Duration(hours: 5)),
        lowPowerModeEnabled: false,
        thermalPressure: ThermalPressure.nominal,
      ));
      expect(d.reason, AdaptiveRefreshReason.longIdle);
      expect(d.delay, const Duration(minutes: 30));
    });

    test('low power mode forces constrained regardless of interaction', () {
      final d = policy.nextDelay(AdaptiveRefreshInput(
        now: now,
        lastMenuOpenAt: now,
        lowPowerModeEnabled: true,
        thermalPressure: ThermalPressure.nominal,
      ));
      expect(d.reason, AdaptiveRefreshReason.constrained);
      expect(d.delay, const Duration(minutes: 30));
    });

    test('thermal constrained forces constrained', () {
      final d = policy.nextDelay(AdaptiveRefreshInput(
        now: now,
        lastMenuOpenAt: now,
        lowPowerModeEnabled: false,
        thermalPressure: ThermalPressure.constrained,
      ));
      expect(d.reason, AdaptiveRefreshReason.constrained);
    });

    test('nominalIntervalForHeuristics is 5 minutes', () {
      expect(
        AdaptiveRefreshPolicyCore.nominalIntervalForHeuristics,
        const Duration(minutes: 5),
      );
    });
  });
}
