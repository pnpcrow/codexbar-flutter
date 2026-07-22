import 'package:flutter/material.dart';

class IconRenderer {
  static const double _baseSize = 18.0;

  static Widget buildTrayIcon({
    required double? primaryRemaining,
    required double? weeklyRemaining,
    double? creditsRemaining,
    required bool stale,
    required String style,
    double blink = 0,
    double wiggle = 0,
    double tilt = 0,
    bool hideCritters = false,
  }) {
    return CustomPaint(
      size: const Size(_baseSize, _baseSize),
      painter: _IconPainter(
        primaryRemaining: primaryRemaining,
        weeklyRemaining: weeklyRemaining,
        creditsRemaining: creditsRemaining,
        stale: stale,
        style: style,
        blink: blink,
        hideCritters: hideCritters,
      ),
    );
  }
}

class _IconPainter extends CustomPainter {
  final double? primaryRemaining;
  final double? weeklyRemaining;
  final double? creditsRemaining;
  final bool stale;
  final String style;
  final double blink;
  final bool hideCritters;

  _IconPainter({
    required this.primaryRemaining,
    required this.weeklyRemaining,
    this.creditsRemaining,
    required this.stale,
    required this.style,
    this.blink = 0,
    this.hideCritters = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = Colors.white;
    final trackFillAlpha = stale ? 0.18 : 0.28;
    final trackStrokeAlpha = stale ? 0.28 : 0.44;
    final fillColor = baseColor.withValues(alpha: stale ? 0.55 : 1.0);

    const barWidth = 15.0;
    final barX = (size.width - barWidth) / 2;

    final hasWeekly = weeklyRemaining != null && weeklyRemaining! > 0;

    if (hasWeekly) {
      _drawBar(
        canvas,
        rect: Rect.fromLTWH(barX, 7, barWidth, 5),
        remaining: primaryRemaining,
        fillColor: fillColor,
        trackFillAlpha: trackFillAlpha,
        trackStrokeAlpha: trackStrokeAlpha,
        addFace: !hideCritters && style == 'codex',
        addNotches: !hideCritters && style == 'claude',
      );
      _drawBar(
        canvas,
        rect: Rect.fromLTWH(barX, 14, barWidth, 4),
        remaining: weeklyRemaining,
        fillColor: fillColor,
        trackFillAlpha: trackFillAlpha,
        trackStrokeAlpha: trackStrokeAlpha,
      );
    } else {
      _drawBar(
        canvas,
        rect: Rect.fromLTWH(barX, 9, barWidth, 8),
        remaining: primaryRemaining,
        fillColor: fillColor,
        trackFillAlpha: trackFillAlpha,
        trackStrokeAlpha: trackStrokeAlpha,
        addFace: !hideCritters && style == 'codex',
        addNotches: !hideCritters && style == 'claude',
      );
    }
  }

  void _drawBar(
    Canvas canvas, {
    required Rect rect,
    required double? remaining,
    required Color fillColor,
    required double trackFillAlpha,
    required double trackStrokeAlpha,
    bool addFace = false,
    bool addNotches = false,
  }) {
    final radius = addNotches ? 0.0 : rect.height / 2;

    // Track fill
    final trackPaint = Paint()
      ..color = fillColor.withValues(alpha: trackFillAlpha)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      trackPaint,
    );

    // Track stroke
    final strokePaint = Paint()
      ..color = fillColor.withValues(alpha: trackStrokeAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      strokePaint,
    );

    // Fill progress
    if (remaining != null) {
      final clamped = (remaining / 100).clamp(0.0, 1.0);
      final fillWidth = rect.width * clamped;
      if (fillWidth > 0) {
        final fillRect = Rect.fromLTWH(
          rect.left,
          rect.top,
          fillWidth,
          rect.height,
        );
        final fillPaint = Paint()
          ..color = fillColor
          ..style = PaintingStyle.fill;

        canvas.save();
        canvas.clipRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(radius)),
        );
        canvas.drawRect(fillRect, fillPaint);
        canvas.restore();
      }
    }

    // Draw face (Codex style)
    if (addFace) {
      _drawFace(canvas, rect, fillColor);
    }

    // Draw notches (Claude style)
    if (addNotches) {
      _drawNotches(canvas, rect, fillColor);
    }
  }

  void _drawFace(Canvas canvas, Rect rect, Color color) {
    final centerX = rect.center.dx;
    final centerY = rect.center.dy;
    final eyeSize = 2.0;
    final eyeOffset = 3.5;

    // Eyes
    final eyePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX - eyeOffset, centerY),
        width: eyeSize,
        height: eyeSize,
      ),
      eyePaint,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX + eyeOffset, centerY),
        width: eyeSize,
        height: eyeSize,
      ),
      eyePaint,
    );

    // Blink
    if (blink > 0.001) {
      final blinkHeight = eyeSize * blink.clamp(0.0, 1.0);
      final blinkPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(
          centerX - eyeOffset - eyeSize / 2,
          centerY - eyeSize / 2,
          eyeSize,
          blinkHeight,
        ),
        blinkPaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(
          centerX + eyeOffset - eyeSize / 2,
          centerY - eyeSize / 2,
          eyeSize,
          blinkHeight,
        ),
        blinkPaint,
      );
    }
  }

  void _drawNotches(Canvas canvas, Rect rect, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Arms
    final armWidth = 1.5;
    final armHeight = rect.height - 3;
    final armY = rect.top + 1.5;

    canvas.drawRect(
      Rect.fromLTWH(rect.left - armWidth, armY, armWidth, armHeight),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(rect.right, armY, armWidth, armHeight),
      paint,
    );

    // Legs
    for (int i = 0; i < 4; i++) {
      final legX = rect.left + (rect.width / 5) * (i + 1);
      canvas.drawRect(
        Rect.fromLTWH(legX - 0.5, rect.top - 1.5, 1, 1.5),
        paint,
      );
    }

    // Eyes
    final eyeWidth = 1.0;
    final eyeHeight = 2.5;
    final eyeOffset = 3.0;
    final eyeY = rect.top + rect.height - eyeHeight - 1;

    canvas.drawRect(
      Rect.fromLTWH(rect.center.dx - eyeOffset - eyeWidth / 2, eyeY, eyeWidth, eyeHeight),
      Paint()..color = Colors.black,
    );
    canvas.drawRect(
      Rect.fromLTWH(rect.center.dx + eyeOffset - eyeWidth / 2, eyeY, eyeWidth, eyeHeight),
      Paint()..color = Colors.black,
    );
  }

  @override
  bool shouldRepaint(covariant _IconPainter oldDelegate) {
    return primaryRemaining != oldDelegate.primaryRemaining ||
        weeklyRemaining != oldDelegate.weeklyRemaining ||
        stale != oldDelegate.stale ||
        blink != oldDelegate.blink;
  }
}
