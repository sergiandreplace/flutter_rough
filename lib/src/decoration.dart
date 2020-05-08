import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rough/rough.dart';

import 'config.dart';

class RoughDrawDecoration {
  final double width;
  final Color color;
  final Gradient gradient;
  final BlendMode blendMode;

//    this.backgroundBlendMode,

//    this.image,
//    this.border,
//    this.borderRadius,
//    this.boxShadow,
  const RoughDrawDecoration({
    this.width,
    this.color,
    this.gradient,
    this.blendMode,
  });
}

class RoughDecoration extends Decoration {
  final BoxShape shape;
  final RoughDrawDecoration roughDrawDecoration;

  const RoughDecoration({
    this.roughDrawDecoration,
    this.shape = BoxShape.rectangle,
  }) : assert(shape != null);

  @override
  EdgeInsetsGeometry get padding => EdgeInsets.all(max(0.1, (roughDrawDecoration?.width ?? 0.1) / 2));

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

  final Paint fillPaint = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true
    ..strokeWidth = 1;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final DrawConfig drawConfig = DrawConfig.build();
    final FillerConfig fillerConfig = FillerConfig.build(drawConfig: drawConfig);
    final Filler filler = NoFiller(fillerConfig);
    final Generator generator = Generator(drawConfig, filler);
    final Rect rect = offset & configuration.size;

    final Paint pathPaint = _buildDrawPaint(roughDecoration.roughDrawDecoration, rect);
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
    canvas.drawRough(drawable, pathPaint, fillPaint);
  }

  Paint _buildDrawPaint(RoughDrawDecoration roughDrawDecoration, Rect rect) {
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
