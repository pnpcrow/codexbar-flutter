import 'package:flutter/material.dart';

/// A horizontal usage progress bar, ported from `UsageProgressBar.swift`.
///
/// Renders a track + left-to-right fill, colored by remaining capacity, with
/// optional warning markers at configured thresholds.
class UsageProgressBar extends StatelessWidget {
  const UsageProgressBar({
    super.key,
    required this.percent,
    this.showUsed = false,
    this.warningThresholds = const [],
    this.height = 8,
  });

  /// Used percent (0–100). The fill width reflects this.
  final double percent;

  /// When true, the bar fills with `used`; when false, it fills with
  /// `remaining` (the icon-meter convention).
  final bool showUsed;

  /// Percents at which to draw warning markers.
  final List<int> warningThresholds;

  final double height;

  @override
  Widget build(BuildContext context) {
    final clamped = percent.clamp(0.0, 100.0) / 100;
    final fill = showUsed ? clamped : (1 - clamped);
    final color = _colorForPercent(percent);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite ? constraints.maxWidth : 200;
        return SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Track
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
              // Fill
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: fill.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
              ),
              // Warning markers
              for (final t in warningThresholds)
                Positioned(
                  left: width * (t / 100) - 1,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    color: Colors.white54,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Color _colorForPercent(double pct) {
    if (pct >= 95) return const Color(0xFFFF3B30);
    if (pct >= 80) return const Color(0xFFFF9500);
    if (pct >= 50) return const Color(0xFFFFCC00);
    return const Color(0xFF34C759);
  }
}
