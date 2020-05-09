import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rough/rough.dart';

import 'config.dart';

class RoughDrawStyle {
  final double width;
  final Color color;
  final Gradient gradient;
  final BlendMode blendMode;

  // TODO: final BorderRadius borderRadius;
//    this.boxShadow,
  const RoughDrawStyle({
    this.width,
    this.color,
    this.gradient,
    this.blendMode,
    // TODO:this.borderRadius,
  });
}

class RoughDecoration extends Decoration {
  final BoxShape shape;
  final RoughDrawStyle borderStyle;
  final DrawConfig drawConfig;
  final RoughDrawStyle fillStyle;
  final Filler filler;
  const RoughDecoration({
    this.borderStyle,
    this.drawConfig,
    this.fillStyle,
    this.shape = BoxShape.rectangle,
    this.filler,
  }) : assert(shape != null);

  @override
  EdgeInsetsGeometry get padding => EdgeInsets.all(max(0.1, (borderStyle?.width ?? 0.1) / 2));

  @override
  BoxPainter createBoxPainter([VoidCallback onChanged]) {
    return RoughDecorationPainter(this);
  }
}

class RoughDecorationPainter extends BoxPainter {
  final RoughDecoration roughDecoration;

  RoughDecorationPainter(
    this.roughDecoration,
  ) : assert(roughDecoration != null);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final DrawConfig drawConfig = roughDecoration.drawConfig ?? DrawConfig.defaultValues;
    final Filler filler = roughDecoration.filler ?? NoFiller();
    final Generator generator = Generator(drawConfig, filler);
    final Rect rect = offset & configuration.size;

    final Paint borderPaint = _buildDrawPaint(roughDecoration.borderStyle, rect);

    final Paint fillPaint = roughDecoration.fillStyle == null ? borderPaint : _buildDrawPaint(roughDecoration.fillStyle, rect);

    Drawable drawable;
    switch (roughDecoration.shape) {
      case BoxShape.rectangle:
        drawable = generator.rectangle(offset.dx, offset.dy, configuration.size.width, configuration.size.height);
        break;
      case BoxShape.circle:
        final double centerX = offset.dx + configuration.size.width / 2;
        final double centerY = offset.dy + configuration.size.height / 2;
        final double diameter = configuration.size.shortestSide;
        drawable = generator.circle(centerX, centerY, diameter);
        break;
    }
    canvas.drawRough(drawable, borderPaint, fillPaint);
  }

  Paint _buildDrawPaint(RoughDrawStyle roughDrawDecoration, Rect rect) {
    const defaultColor = Color(0x00000000);
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.square
      ..strokeWidth = roughDrawDecoration?.width ?? 0.1
      ..color = roughDrawDecoration?.color ?? defaultColor
      ..shader = roughDrawDecoration?.gradient?.createShader(rect);
    if (roughDrawDecoration?.blendMode != null) {
      paint.blendMode = roughDrawDecoration.blendMode;
    }

    return paint;
  }
}
