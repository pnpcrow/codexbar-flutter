import 'package:flutter/material.dart';

/// Usage progress bar widget.
/// Direct port of Swift UsageProgressBar.
class UsageProgressBar extends StatelessWidget {
  final double usedPercent;
  final String? label;
  final double height;

  const UsageProgressBar({
    super.key,
    required this.usedPercent,
    this.label,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final clampedPercent = usedPercent.clamp(0, 100) / 100;
    final color = _getColor(clampedPercent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${(clampedPercent * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: clampedPercent,
            minHeight: height,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Color _getColor(double percent) {
    if (percent >= 0.9) return Colors.red;
    if (percent >= 0.7) return Colors.orange;
    if (percent >= 0.5) return Colors.yellow.shade700;
    return Colors.green;
  }
}
