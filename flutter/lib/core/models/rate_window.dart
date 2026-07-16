import 'package:flutter/foundation.dart';

/// A single usage rate-limit window for a provider.
///
/// Ported from `Sources/CodexBarCore/UsageFetcher.swift` `RateWindow`.
/// Most providers expose a primary (session) and secondary (weekly) window.
@immutable
class RateWindow {
  const RateWindow({
    required this.usedPercent,
    this.windowMinutes,
    this.resetsAt,
    this.resetDescription,
    this.nextRegenPercent,
    this.isSyntheticPlaceholder = false,
  });

  /// Percent of the quota that has been used (0–100).
  final double usedPercent;

  /// Length of the rolling window in minutes, if known.
  final int? windowMinutes;

  /// When the window resets and usage clears, if known.
  final DateTime? resetsAt;

  /// Optional human-readable reset description (used by Claude CLI UI scrape).
  final String? resetDescription;

  /// Optional percent restored on the next regeneration tick for providers
  /// with rolling recovery.
  final double? nextRegenPercent;

  /// Whether this window was synthesized to stand in for a quota lane the
  /// provider did not actually report (e.g. Claude web's null five-hour lane).
  final bool isSyntheticPlaceholder;

  /// Remaining percent of the quota (0–100), never negative.
  double get remainingPercent => usedPercent > 100 ? 0 : 100 - usedPercent;

  /// Backfill a missing reset time from a prior cached window, preserving the
  /// placeholder marker. Ported from `RateWindow.backfillingResetTime`.
  RateWindow backfillingResetTime(RateWindow? cached, {DateTime? now}) {
    if (resetsAt != null) return this;
    final now_ = now ?? DateTime.now();
    final cachedReset = cached?.resetsAt;
    if (cachedReset == null || !cachedReset.isAfter(now_)) return this;
    final minutes = (windowMinutes != null && windowMinutes! > 0)
        ? windowMinutes
        : cached?.windowMinutes;
    return RateWindow(
      usedPercent: usedPercent,
      windowMinutes: minutes,
      resetsAt: cachedReset,
      resetDescription: resetDescription ?? cached?.resetDescription,
      nextRegenPercent: nextRegenPercent,
      isSyntheticPlaceholder: isSyntheticPlaceholder,
    );
  }

  factory RateWindow.fromJson(Map<String, dynamic> json) {
    return RateWindow(
      usedPercent: (json['usedPercent'] as num).toDouble(),
      windowMinutes: json['windowMinutes'] as int?,
      resetsAt: _parseDate(json['resetsAt']),
      resetDescription: json['resetDescription'] as String?,
      nextRegenPercent: (json['nextRegenPercent'] as num?)?.toDouble(),
      isSyntheticPlaceholder: (json['isSyntheticPlaceholder'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'usedPercent': usedPercent,
    };
    if (windowMinutes != null) json['windowMinutes'] = windowMinutes;
    if (resetsAt != null) json['resetsAt'] = resetsAt!.toIso8601String();
    if (resetDescription != null) json['resetDescription'] = resetDescription;
    if (nextRegenPercent != null) json['nextRegenPercent'] = nextRegenPercent;
    if (isSyntheticPlaceholder) json['isSyntheticPlaceholder'] = true;
    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RateWindow &&
          other.usedPercent == usedPercent &&
          other.windowMinutes == windowMinutes &&
          other.resetsAt == resetsAt &&
          other.resetDescription == resetDescription &&
          other.nextRegenPercent == nextRegenPercent &&
          other.isSyntheticPlaceholder == isSyntheticPlaceholder;

  @override
  int get hashCode => Object.hash(
        usedPercent,
        windowMinutes,
        resetsAt,
        resetDescription,
        nextRegenPercent,
        isSyntheticPlaceholder,
      );
}

/// An additional named rate window beyond primary/secondary/tertiary.
///
/// Ported from `NamedRateWindow` in `UsageFetcher.swift`.
@immutable
class NamedRateWindow {
  const NamedRateWindow({
    required this.id,
    required this.title,
    required this.window,
    this.usageKnown = true,
  });

  final String id;
  final String title;
  final RateWindow window;

  /// Whether [window.usedPercent] reflects known quota usage. Some providers
  /// expose reset metadata before remaining usage; keep such windows visible
  /// but do not render `usedPercent` as a real exhausted quota.
  final bool usageKnown;

  factory NamedRateWindow.fromJson(Map<String, dynamic> json) {
    return NamedRateWindow(
      id: json['id'] as String,
      title: json['title'] as String,
      window: RateWindow.fromJson(json['window'] as Map<String, dynamic>),
      usageKnown: (json['usageKnown'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': id,
      'title': title,
      'window': window.toJson(),
    };
    if (!usageKnown) json['usageKnown'] = false;
    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NamedRateWindow &&
          other.id == id &&
          other.title == title &&
          other.window == window &&
          other.usageKnown == usageKnown;

  @override
  int get hashCode => Object.hash(id, title, window, usageKnown);
}

DateTime? _parseDate(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt() * 1000, isUtc: true);
  }
  return DateTime.tryParse(value.toString());
}
