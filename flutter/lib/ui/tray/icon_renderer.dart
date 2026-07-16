import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../../core/models/usage_provider.dart';

/// Renders the CodexBar menu-bar icon: two stacked horizontal meter bars with
/// an optional provider "critter" personality, status overlay, and stale
/// dimming.
///
/// Ported from `Sources/CodexBar/IconRenderer.swift`, keeping the core visual
/// contract: an 18×18pt canvas rendered at 2× (36×36px) with a fixed pixel
/// grid, two meter bars (primary on top, secondary below), track + left-to-
/// right fill + crisp outline, stale dimming, and a status overlay
/// (dot/exclamation) in the top-right corner.
///
/// The 60 per-provider critter personalities are reduced to the two signature
/// ones (Codex capsule-with-eyes, Claude blocky crab) plus a plain bar for
/// all others; see `docs/upstream/DECISIONS.md`.
@immutable
class IconInput {
  const IconInput({
    this.primaryRemaining,
    this.secondaryRemaining,
    this.creditsRemaining,
    this.stale = false,
    this.style = IconStyle.combined,
    this.blink = 0,
    this.wiggle = 0,
    this.tilt = 0,
    this.statusIndicator = ProviderStatusIndicator.none,
    this.hideCritters = false,
  });

  /// Remaining percent (0–100) for the primary (session) bar.
  final double? primaryRemaining;

  /// Remaining percent (0–100) for the secondary (weekly/bonus) bar.
  final double? secondaryRemaining;

  /// Remaining credits percent (0–100), when a provider surfaces credits.
  final double? creditsRemaining;

  /// When true, dim alphas to indicate stale/error state.
  final bool stale;

  /// Provider icon style, selecting the critter personality.
  final IconStyle style;

  /// 0–1 blink animation amount.
  final double blink;

  /// 0–1 wiggle animation amount.
  final double wiggle;

  /// 0–1 tilt animation amount (radians-ish).
  final double tilt;

  /// Optional provider status overlay.
  final ProviderStatusIndicator statusIndicator;

  /// Suppress the critter personality, rendering plain meter bars.
  final bool hideCritters;
}

/// A [CustomPainter] that draws the CodexBar meter icon on a 36×36px grid.
///
/// The canvas is square with side [IconRenderer.size]; paint is driven by an
/// [IconInput]. Drawing is pixel-aligned to a 2× grid for crisp edges.
class IconPainter extends CustomPainter {
  IconPainter({required this.input, this.color = const Color(0xFF000000)});

  final IconInput input;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw into the full canvas; coordinates are in points (0..size.width).
    final grid = _PixelGrid(scale: size.width / IconRenderer.canvasPx);

    final baseFill = color;
    final trackFillAlpha = input.stale ? 0.18 : 0.28;
    final trackStrokeAlpha = input.stale ? 0.28 : 0.44;
    final fillAlpha = input.stale ? 0.55 : 1.0;

    final barWidthPx = IconRenderer.barWidthPx;
    final barXPx = (IconRenderer.canvasPx - barWidthPx) ~/ 2;

    // Layout: two stacked bars. With both windows present, top = primary,
    // bottom = secondary. When secondary is absent, the primary bar grows
    // taller and the lower bar is dimmed/empty.
    final hasSecondary = input.secondaryRemaining != null;
    final topBarH = hasSecondary ? 8 : 12;
    final bottomBarH = 8;
    final gapPx = 2;
    final totalH = topBarH + gapPx + bottomBarH;
    final topY = (IconRenderer.canvasPx - totalH) ~/ 2;
    final bottomY = topY + topBarH + gapPx;

    final showCritter = !input.hideCritters && input.style != IconStyle.combined;
    final isCodex = showCritter && input.style == IconStyle.codex;
    final isClaude = showCritter && input.style == IconStyle.claude;

    _drawBar(
      canvas,
      grid,
      rectPx: _RectPx(barXPx, topY, barWidthPx, topBarH),
      remaining: input.primaryRemaining,
      baseFill: baseFill,
      trackFillAlpha: trackFillAlpha,
      trackStrokeAlpha: trackStrokeAlpha,
      fillAlpha: fillAlpha,
      addFace: isCodex,
      addNotches: isClaude,
      blink: input.blink,
      wiggle: input.wiggle,
      tilt: input.tilt,
      cornerRadiusPx: isClaude ? 0 : null,
    );

    _drawBar(
      canvas,
      grid,
      rectPx: _RectPx(barXPx, bottomY, barWidthPx, bottomBarH),
      remaining: input.secondaryRemaining ?? input.creditsRemaining,
      baseFill: baseFill,
      trackFillAlpha: trackFillAlpha * (hasSecondary ? 1.0 : 0.6),
      trackStrokeAlpha: trackStrokeAlpha * (hasSecondary ? 1.0 : 0.6),
      fillAlpha: fillAlpha,
    );

    _drawStatusOverlay(canvas, grid, input.statusIndicator, baseFill);
  }

  void _drawBar(
    Canvas canvas,
    _PixelGrid grid, {
    required _RectPx rectPx,
    required double? remaining,
    required Color baseFill,
    required double trackFillAlpha,
    required double trackStrokeAlpha,
    required double fillAlpha,
    bool addFace = false,
    bool addNotches = false,
    double blink = 0,
    double wiggle = 0,
    double tilt = 0,
    int? cornerRadiusPx,
  }) {
    final rect = rectPx.rect(grid);
    final radius = grid.pt(cornerRadiusPx ?? rectPx.h ~/ 2);

    // Track fill.
    final trackPaint = Paint()
      ..color = baseFill.withValues(alpha: trackFillAlpha)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      trackPaint,
    );

    // Crisp outline, inset so the stroke stays within pixel bounds.
    const strokeWidthPx = 2;
    const insetPx = strokeWidthPx / 2;
    final strokeRect = grid.rect(
      x: rectPx.x + insetPx,
      y: rectPx.y + insetPx,
      w: math.max(0.0, rectPx.w - insetPx * 2),
      h: math.max(0.0, rectPx.h - insetPx * 2),
    );
    final strokeRadius = grid.pt(math.max(0.0, (cornerRadiusPx ?? (rectPx.h ~/ 2)) - insetPx));
    final strokePaint = Paint()
      ..color = baseFill.withValues(alpha: trackStrokeAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidthPx / IconRenderer.outputScale;
    canvas.drawRRect(
      RRect.fromRectAndRadius(strokeRect, Radius.circular(strokeRadius)),
      strokePaint,
    );

    // Fill: clip to the capsule and paint a left-to-right rect so the progress
    // edge is straight.
    if (remaining != null) {
      final clamped = (remaining / 100).clamp(0.0, 1.0);
      final fillWidthPx = (rectPx.w * clamped).round();
      if (fillWidthPx > 0) {
        final fillRect = grid.rect(
          x: rectPx.x,
          y: rectPx.y,
          w: fillWidthPx.toDouble(),
          h: rectPx.h.toDouble(),
        );
        canvas.save();
        canvas.clipRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
        canvas.drawRect(
          fillRect,
          Paint()..color = baseFill.withValues(alpha: fillAlpha),
        );
        canvas.restore();
      }
    }

    if (addFace) {
      _drawCodexFace(canvas, grid, rectPx, baseFill, fillAlpha, blink, tilt);
    }
    if (addNotches) {
      _drawClaudeCrab(canvas, grid, rectPx, baseFill, fillAlpha, blink, wiggle);
    }
  }

  /// Codex personality: two square eye cutouts + a tiny hovering hat.
  void _drawCodexFace(
    Canvas canvas,
    _PixelGrid grid,
    _RectPx rectPx,
    Color fill,
    double alpha,
    double blink,
    double tilt,
  ) {
    const eyeSizePx = 4;
    const eyeOffsetPx = 7;
    final eyeCenterYPx = rectPx.y + rectPx.h ~/ 2;
    final centerXPx = rectPx.midX;

    // Eye cutouts: clear by painting transparent (destination-out blend).
    final clearPaint = Paint()..blendMode = BlendMode.dstOut;
    for (final dx in const [-eyeOffsetPx, eyeOffsetPx]) {
      canvas.drawRect(
        grid.rect(
          x: centerXPx + dx - eyeSizePx ~/ 2,
          y: eyeCenterYPx - eyeSizePx ~/ 2,
          w: eyeSizePx,
          h: eyeSizePx,
        ),
        clearPaint,
      );
    }

    // Blink: refill eyes from the top down using the bar fill color.
    if (blink > 0.001) {
      final clamped = blink.clamp(0.0, 1.0);
      final blinkHeightPx = (eyeSizePx * clamped).round();
      for (final dx in const [-eyeOffsetPx, eyeOffsetPx]) {
        canvas.drawRect(
          grid.rect(
            x: centerXPx + dx - eyeSizePx ~/ 2,
            y: eyeCenterYPx + eyeSizePx ~/ 2 - blinkHeightPx,
            w: eyeSizePx,
            h: blinkHeightPx,
          ),
          Paint()..color = fill.withValues(alpha: alpha),
        );
      }
    }

    // Hat: a tiny cap hovering above the eyes.
    const hatWidthPx = 18;
    const hatHeightPx = 4;
    final hatRect = grid.rect(
      x: centerXPx - hatWidthPx ~/ 2,
      y: rectPx.y + rectPx.h - hatHeightPx,
      w: hatWidthPx,
      h: hatHeightPx,
    );
    canvas.save();
    if (tilt.abs() > 0.0001) {
      final faceCenter = Offset(
        grid.pt(centerXPx),
        grid.pt(eyeCenterYPx),
      );
      canvas
        ..translate(faceCenter.dx, faceCenter.dy)
        ..rotate(tilt)
        ..translate(-faceCenter.dx, -faceCenter.dy - tilt.abs() * 1.2);
    }
    canvas.drawRect(hatRect, Paint()..color = fill.withValues(alpha: alpha));
    canvas.restore();
  }

  /// Claude personality: blocky crab — side arms, 4 legs, vertical eye cutouts.
  void _drawClaudeCrab(
    Canvas canvas,
    _PixelGrid grid,
    _RectPx rectPx,
    Color fill,
    double alpha,
    double blink,
    double wiggle,
  ) {
    final wigglePx = (grid.snapDelta(wiggle * 0.6) * IconRenderer.outputScale).round();
    final crabPaint = Paint()..color = fill.withValues(alpha: alpha);

    // Arms/claws: mid-height side protrusions.
    const armWidthPx = 3;
    final armHeightPx = math.max(0, rectPx.h - 6);
    final armYPx = rectPx.y + 3 + wigglePx ~/ 6;
    canvas.drawRect(
      grid.rect(x: rectPx.x - armWidthPx, y: armYPx, w: armWidthPx, h: armHeightPx),
      crabPaint,
    );
    canvas.drawRect(
      grid.rect(x: rectPx.x + rectPx.w, y: armYPx, w: armWidthPx, h: armHeightPx),
      crabPaint,
    );

    // Legs: 4 little pixels underneath.
    const legCount = 4;
    const legWidthPx = 2;
    const legHeightPx = 3;
    final legYPx = rectPx.y - legHeightPx + wigglePx ~/ 6;
    final stepPx = math.max(1, rectPx.w ~/ (legCount + 1));
    for (var i = 0; i < legCount; i++) {
      final cx = rectPx.x + stepPx * (i + 1);
      canvas.drawRect(
        grid.rect(
          x: cx - legWidthPx ~/ 2,
          y: legYPx,
          w: legWidthPx,
          h: legHeightPx,
        ),
        crabPaint,
      );
    }

    // Eyes: tall vertical cutouts near the top.
    const eyeWidthPx = 2;
    const eyeHeightPx = 5;
    const eyeOffsetPx = 6;
    final eyeYPx = rectPx.y + rectPx.h - eyeHeightPx - 2 + wigglePx ~/ 8;
    final clearPaint = Paint()..blendMode = BlendMode.dstOut;
    for (final dx in const [-eyeOffsetPx, eyeOffsetPx]) {
      canvas.drawRect(
        grid.rect(
          x: rectPx.midX + dx - eyeWidthPx ~/ 2,
          y: eyeYPx,
          w: eyeWidthPx,
          h: eyeHeightPx,
        ),
        clearPaint,
      );
    }

    // Blink: fill eyes from the top down.
    if (blink > 0.001) {
      final clamped = blink.clamp(0.0, 1.0);
      final blinkHeightPx = (eyeHeightPx * clamped).round();
      for (final dx in const [-eyeOffsetPx, eyeOffsetPx]) {
        canvas.drawRect(
          grid.rect(
            x: rectPx.midX + dx - eyeWidthPx ~/ 2,
            y: eyeYPx + eyeHeightPx - blinkHeightPx,
            w: eyeWidthPx,
            h: blinkHeightPx,
          ),
          Paint()..color = fill.withValues(alpha: alpha),
        );
      }
    }
  }

  /// Status overlay: a small dot for minor/maintenance, a dot+line for major/
  /// critical/unknown, drawn in the top-right corner with a clear halo.
  void _drawStatusOverlay(
    Canvas canvas,
    _PixelGrid grid,
    ProviderStatusIndicator indicator,
    Color fill,
  ) {
    if (!indicator.hasIssue) return;
    const dotPx = 4;
    const xPx = IconRenderer.canvasPx - dotPx - 1;
    const yPx = 1;

    // Halo (clear blend) so the marker reads on the bar.
    canvas.save();
    canvas.drawRect(
      grid.rect(x: xPx - 1, y: yPx - 1, w: dotPx + 2, h: dotPx + 2),
      Paint()..blendMode = BlendMode.dstOut,
    );
    canvas.restore();

    final issueColor = switch (indicator) {
      ProviderStatusIndicator.critical => const Color(0xFFFF3B30),
      ProviderStatusIndicator.major => const Color(0xFFFF9500),
      ProviderStatusIndicator.minor => const Color(0xFFFFCC00),
      ProviderStatusIndicator.maintenance => const Color(0xFF007AFF),
      _ => fill,
    };
    canvas.drawRect(
      grid.rect(x: xPx, y: yPx, w: dotPx, h: dotPx),
      Paint()..color = issueColor,
    );

    // Exclamation line for major/critical/unknown.
    if (indicator == ProviderStatusIndicator.major ||
        indicator == ProviderStatusIndicator.critical ||
        indicator == ProviderStatusIndicator.unknown) {
      canvas.drawRect(
        grid.rect(x: xPx + dotPx ~/ 2 - 1 ~/ 2, y: yPx + 1, w: 2, h: dotPx - 2),
        Paint()..color = const Color(0xFFFFFFFF),
      );
    }
  }

  @override
  bool shouldRepaint(covariant IconPainter old) => old.input != input || old.color != color;
}

/// Convenience namespace for icon constants. Kept as a class (not enum) so the
/// constants read like a namespace, matching the Swift `enum IconRenderer`.
class IconRenderer {
  const IconRenderer._();

  static const double outputSize = 18;
  static const double outputScale = 2;
  static const int canvasPx = 36;
  static const int barWidthPx = 30;
  static const double creditsCap = 1000;

  /// Logical icon size in points (matches the macOS menu bar).
  static const double size = outputSize;

  /// Rasterize an [IconInput] to PNG bytes at 2× scale, suitable for
  /// [TrayManager.setImage]. The image is rendered on a transparent background.
  ///
  /// Must be called from a context with a valid [PaintingBinding] (e.g. inside
  /// the app); the caller is responsible for platform-channel bridging.
  static Future<Uint8List> rasterizeToPng(IconInput input, {Color color = const Color(0xFF000000)}) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    IconPainter(input: input, color: color).paint(canvas, const Size(36, 36));
    final picture = recorder.endRecording();
    final image = await picture.toImage(canvasPx, canvasPx);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}

/// Pixel-grid helper mirroring Swift's `PixelGrid` + `RectPx`.
class _PixelGrid {
  const _PixelGrid({required this.scale});

  final double scale;

  double pt(num px) => px / scale;

  ui.Rect rect({
    required num x,
    required num y,
    required num w,
    required num h,
  }) =>
      ui.Rect.fromLTWH(pt(x.toInt()), pt(y.toInt()), pt(w.toInt()), pt(h.toInt()));

  double snapDelta(double value) => (value * scale).round() / scale;
}

@immutable
class _RectPx {
  const _RectPx(this.x, this.y, this.w, this.h);

  final int x;
  final int y;
  final int w;
  final int h;

  int get midX => x + w ~/ 2;
  int get midY => y + h ~/ 2;

  ui.Rect rect(_PixelGrid grid) => grid.rect(x: x, y: y, w: w, h: h);
}
