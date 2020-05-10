import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rough/rough.dart';

import 'config.dart';

class RoughDrawingStyle {
  final double width;
  final Color color;
  final Gradient gradient;
  final BlendMode blendMode;
  // TODO: final BorderRadius borderRadius;
  // TODO:   this.boxShadow?,

  const RoughDrawingStyle({
    this.width,
    this.color,
    this.gradient,
    this.blendMode,
  });
}

/// The shape to use when rendering a [RoughBoxDecoration].
///
enum RoughBoxShape {
  /// An axis-aligned, 2D rectangle. May have rounded corners (described by a
  /// [BorderRadius]). The center of edges of the rectangle will match the
  /// edges of the box into which the [RoughBoxDecoration] is painted.
  rectangle,

  /// A circle centered in the middle of the box into which the [Border] or
  /// [BoxDecoration] is painted. The diameter of the circle is the shortest
  /// dimension of the box, either the width or the height, such that the circle
  /// path center touches the edges of the box.
  circle,

  /// An ellipse centered in the middle of the box into which the [Border] or
  /// [BoxDecoration] is painted. The horizontal diameter of the ellipse is the width
  /// the box and the vertical diameter is the height of the box, such that the ellipse
  /// path center touches the edges of the box.
  ellipse,
}

class RoughBoxDecoration extends Decoration {
  final RoughBoxShape shape;
  final RoughDrawingStyle borderStyle;
  final DrawConfig drawConfig;
  final RoughDrawingStyle fillStyle;
  final Filler filler;
  const RoughBoxDecoration({
    this.borderStyle,
    this.drawConfig,
    this.fillStyle,
    this.shape = RoughBoxShape.rectangle,
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
  final RoughBoxDecoration roughDecoration;

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
      case RoughBoxShape.rectangle:
        drawable = generator.rectangle(offset.dx, offset.dy, configuration.size.width, configuration.size.height);
        break;
      case RoughBoxShape.circle:
        final double centerX = offset.dx + configuration.size.width / 2;
        final double centerY = offset.dy + configuration.size.height / 2;
        final double diameter = configuration.size.shortestSide;
        drawable = generator.circle(centerX, centerY, diameter);
        break;
      case RoughBoxShape.ellipse:
        final double centerX = offset.dx + configuration.size.width / 2;
        final double centerY = offset.dy + configuration.size.height / 2;

        drawable = generator.ellipse(centerX, centerY, configuration.size.width, configuration.size.height);
        break;
    }
    canvas.drawRough(drawable, borderPaint, fillPaint);
  }

  Paint _buildDrawPaint(RoughDrawingStyle roughDrawDecoration, Rect rect) {
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
