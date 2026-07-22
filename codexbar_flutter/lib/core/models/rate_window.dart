import 'package:freezed_annotation/freezed_annotation.dart';

part 'rate_window.freezed.dart';
part 'rate_window.g.dart';

@freezed
class RateWindow with _$RateWindow {
  const factory RateWindow({
    required double usedPercent,
    int? windowMinutes,
    DateTime? resetsAt,
    String? resetDescription,
    double? nextRegenPercent,
    @Default(false) bool isSyntheticPlaceholder,
  }) = _RateWindow;

  factory RateWindow.fromJson(Map<String, dynamic> json) =>
      _$RateWindowFromJson(json);
}

extension RateWindowX on RateWindow {
  double get remainingPercent => (100 - usedPercent).clamp(0, 100);

  String? get resetDescription_ {
    if (resetsAt == null) return resetDescription;
    final now = DateTime.now();
    final diff = resetsAt!.difference(now);
    if (diff.isNegative) return 'Resetting...';
    if (diff.inHours > 0) {
      return '${diff.inHours}h ${diff.inMinutes % 60}m';
    }
    return '${diff.inMinutes}m';
  }
}

@freezed
class NamedRateWindow with _$NamedRateWindow {
  const factory NamedRateWindow({
    required String id,
    required String title,
    required RateWindow window,
    @Default(true) bool usageKnown,
  }) = _NamedRateWindow;

  factory NamedRateWindow.fromJson(Map<String, dynamic> json) =>
      _$NamedRateWindowFromJson(json);
}
