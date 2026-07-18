/// Represents a usage rate window (e.g., session limit, weekly limit).
/// Direct port of Swift RateWindow from CodexBarCore.
class RateWindow {
  final double usedPercent;
  final int? windowMinutes;
  final DateTime? resetsAt;
  final String? resetDescription;
  final double? nextRegenPercent;
  final bool isSyntheticPlaceholder;

  const RateWindow({
    required this.usedPercent,
    this.windowMinutes,
    this.resetsAt,
    this.resetDescription,
    this.nextRegenPercent,
    this.isSyntheticPlaceholder = false,
  });

  double get remainingPercent => (100 - usedPercent).clamp(0, 100);

  RateWindow backfillingResetTime({RateWindow? cached, DateTime? now}) {
    now ??= DateTime.now();
    if (resetsAt != null) return this;
    final cachedReset = cached?.resetsAt;
    if (cachedReset == null || cachedReset.isBefore(now)) return this;
    final resolvedWindowMinutes =
        (windowMinutes != null && windowMinutes! > 0)
            ? windowMinutes
            : cached?.windowMinutes;
    return RateWindow(
      usedPercent: usedPercent,
      windowMinutes: resolvedWindowMinutes,
      resetsAt: cachedReset,
      resetDescription: resetDescription ?? cached?.resetDescription,
      nextRegenPercent: nextRegenPercent,
      isSyntheticPlaceholder: isSyntheticPlaceholder,
    );
  }

  factory RateWindow.fromJson(Map<String, dynamic> json) => RateWindow(
        usedPercent: (json['usedPercent'] as num).toDouble(),
        windowMinutes: json['windowMinutes'] as int?,
        resetsAt: json['resetsAt'] != null
            ? DateTime.parse(json['resetsAt'] as String)
            : null,
        resetDescription: json['resetDescription'] as String?,
        nextRegenPercent: (json['nextRegenPercent'] as num?)?.toDouble(),
        isSyntheticPlaceholder: json['isSyntheticPlaceholder'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'usedPercent': usedPercent,
        if (windowMinutes != null) 'windowMinutes': windowMinutes,
        if (resetsAt != null) 'resetsAt': resetsAt!.toIso8601String(),
        if (resetDescription != null) 'resetDescription': resetDescription,
        if (nextRegenPercent != null) 'nextRegenPercent': nextRegenPercent,
        if (isSyntheticPlaceholder) 'isSyntheticPlaceholder': true,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RateWindow &&
          usedPercent == other.usedPercent &&
          windowMinutes == other.windowMinutes &&
          resetsAt == other.resetsAt &&
          isSyntheticPlaceholder == other.isSyntheticPlaceholder;

  @override
  int get hashCode => Object.hash(
        usedPercent,
        windowMinutes,
        resetsAt,
        isSyntheticPlaceholder,
      );
}

/// A named rate window with an identifier and title.
class NamedRateWindow {
  final String id;
  final String title;
  final RateWindow window;
  final bool usageKnown;

  const NamedRateWindow({
    required this.id,
    required this.title,
    required this.window,
    this.usageKnown = true,
  });

  factory NamedRateWindow.fromJson(Map<String, dynamic> json) =>
      NamedRateWindow(
        id: json['id'] as String,
        title: json['title'] as String,
        window: RateWindow.fromJson(json['window'] as Map<String, dynamic>),
        usageKnown: json['usageKnown'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'window': window.toJson(),
        if (!usageKnown) 'usageKnown': false,
      };
}
