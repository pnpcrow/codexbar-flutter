import 'package:flutter/material.dart';

class UsageProgressBar extends StatelessWidget {
  final double percent;
  final Color color;
  final double height;
  final String? accessibilityLabel;
  final double? pacePercent;

  const UsageProgressBar({
    super.key,
    required this.percent,
    required this.color,
    this.height = 8.0,
    this.accessibilityLabel,
    this.pacePercent,
  });

  @override
  Widget build(BuildContext context) {
    final clampedPercent = percent.clamp(0.0, 100.0) / 100.0;
    final theme = Theme.of(context);

    return Semantics(
      label: accessibilityLabel,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: Stack(
            children: [
              // Main fill
              FractionallySizedBox(
                widthFactor: clampedPercent,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
              ),
              // Pace indicator
              if (pacePercent != null)
                Positioned(
                  left: (pacePercent!.clamp(0.0, 100.0) / 100.0) * 100,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    color: color.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
