import 'package:flutter_test/flutter_test.dart';

import 'package:codexbar/core/models/credits_snapshot.dart';
import 'package:codexbar/core/models/provider_cost.dart';
import 'package:codexbar/core/models/provider_identity.dart';
import 'package:codexbar/core/models/rate_window.dart';
import 'package:codexbar/core/models/usage_provider.dart';
import 'package:codexbar/core/models/usage_snapshot.dart';

void main() {
  group('RateWindow', () {
    test('remainingPercent is 100 - usedPercent, clamped at 0', () {
      expect(const RateWindow(usedPercent: 30).remainingPercent, 70);
      expect(const RateWindow(usedPercent: 100).remainingPercent, 0);
      expect(const RateWindow(usedPercent: 150).remainingPercent, 0);
    });

    test('backfillingResetTime copies reset from a cached window when missing', () {
      final cachedReset = DateTime.utc(2026, 7, 16, 12);
      final cached = RateWindow(
        usedPercent: 10,
        windowMinutes: 300,
        resetsAt: cachedReset,
      );
      final fresh = const RateWindow(usedPercent: 40);
      final backfilled = fresh.backfillingResetTime(cached);
      expect(backfilled.resetsAt, cachedReset);
      expect(backfilled.windowMinutes, 300);
      expect(backfilled.usedPercent, 40);
    });

    test('backfillingResetTime is a no-op when a reset is already present', () {
      final reset = DateTime.utc(2026, 7, 16, 12);
      final fresh = RateWindow(usedPercent: 40, resetsAt: reset);
      expect(fresh.backfillingResetTime(null).resetsAt, reset);
    });

    test('JSON round-trip preserves fields', () {
      const window = RateWindow(
        usedPercent: 42,
        windowMinutes: 300,
        resetDescription: 'in 5h',
        nextRegenPercent: 5,
        isSyntheticPlaceholder: true,
      );
      final json = window.toJson();
      final restored = RateWindow.fromJson(json);
      expect(restored, window);
    });
  });

  group('UsageSnapshot', () {
    test('hasData is false with no windows and no cost', () {
      final snap = UsageSnapshot(updatedAt: DateTime.utc(2026, 7, 16));
      expect(snap.hasData, isFalse);
    });

    test('hasData is true with a primary window', () {
      final snap = UsageSnapshot(
        primary: const RateWindow(usedPercent: 10),
        updatedAt: DateTime.utc(2026, 7, 16),
      );
      expect(snap.hasData, isTrue);
    });

    test('JSON round-trip preserves primary/secondary/cost', () {
      final snap = UsageSnapshot(
        primary: const RateWindow(usedPercent: 20),
        secondary: const RateWindow(usedPercent: 5),
        providerCost: ProviderCostSnapshot(
          used: 3.5,
          limit: 100,
          currencyCode: 'USD',
          period: 'Monthly',
          updatedAt: DateTime.utc(2026, 7, 16),
        ),
        identity: const ProviderIdentitySnapshot(
          providerID: UsageProvider.openai,
          accountEmail: 'a@b.com',
        ),
        updatedAt: DateTime.utc(2026, 7, 16, 12),
      );
      final restored = UsageSnapshot.fromJson(snap.toJson());
      expect(restored.primary?.usedPercent, 20);
      expect(restored.secondary?.usedPercent, 5);
      expect(restored.providerCost?.used, 3.5);
      expect(restored.identity?.accountEmail, 'a@b.com');
    });
  });

  group('ProviderCostSnapshot', () {
    test('usedPercent clamps to 0–100', () {
      expect(
        ProviderCostSnapshot(
          used: 50,
          limit: 100,
          currencyCode: 'USD',
          updatedAt: DateTime.utc(2026, 7, 16),
        ).usedPercent,
        50,
      );
      expect(
        ProviderCostSnapshot(
          used: 150,
          limit: 100,
          currencyCode: 'USD',
          updatedAt: DateTime.utc(2026, 7, 16),
        ).usedPercent,
        100,
      );
      expect(
        ProviderCostSnapshot(
          used: 10,
          limit: 0,
          currencyCode: 'USD',
          updatedAt: DateTime.utc(2026, 7, 16),
        ).usedPercent,
        100,
      );
    });
  });

  group('CodexCreditLimitSnapshot', () {
    final updatedAt = DateTime.utc(2026, 7, 16);

    test('usedPercent is derived from remainingPercent', () {
      final snap = CodexCreditLimitSnapshot(
        used: 80,
        limit: 100,
        remaining: 20,
        remainingPercent: 20,
        updatedAt: updatedAt,
      );
      expect(snap.usedPercent, 80);
    });

    test('usedPercent clamps to 0–100', () {
      expect(
        CodexCreditLimitSnapshot(
          used: 0,
          limit: 100,
          remaining: 100,
          remainingPercent: 150,
          updatedAt: updatedAt,
        ).usedPercent,
        0,
      );
      expect(
        CodexCreditLimitSnapshot(
          used: 0,
          limit: 100,
          remaining: 0,
          remainingPercent: -10,
          updatedAt: updatedAt,
        ).usedPercent,
        100,
      );
    });
  });

  group('UsageProvider', () {
    test('all has 60 entries', () {
      expect(UsageProvider.all.length, 60);
    });

    test('fromString resolves known names case-insensitively', () {
      expect(UsageProvider.fromString('openai'), UsageProvider.openai);
      expect(UsageProvider.fromString('OpenAI'), UsageProvider.openai);
      expect(UsageProvider.fromString('claude'), UsageProvider.claude);
      expect(UsageProvider.fromString('nope'), isNull);
    });

    test('equality is by name', () {
      expect(UsageProvider.openai == UsageProvider.fromString('openai'), isTrue);
      expect(UsageProvider.openai == UsageProvider.claude, isFalse);
    });
  });
}
