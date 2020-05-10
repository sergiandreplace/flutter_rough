import 'package:flutter/material.dart';

import 'core.dart';
import 'entities.dart';

/// This is the base Rough class for painting
extension Rough on Canvas {
  Path _drawToContext(OpSet drawing) {
    final Path path = Path();
    for (final Op op in drawing.ops) {
      final data = op.data;
      switch (op.op) {
        case OpType.move:
          path.moveTo(data[0].x, data[0].y);
          break;
        case OpType.curveTo:
          path.cubicTo(data[0].x, data[0].y, data[1].x, data[1].y, data[2].x, data[2].y);
          break;
        case OpType.lineTo:
          path.lineTo(data[0].x, data[0].y);
          break;
      }
    }
    return path;
  }

  /// Draws a rough Drawable
  ///
  ///
  void drawRough(Drawable drawable, Paint pathPaint, Paint fillPaint) {
    for (final OpSet drawing in drawable.sets ?? []) {
      switch (drawing.type) {
        case OpSetType.path:
          drawPath(_drawToContext(drawing), pathPaint);
          ;
          break;
        case OpSetType.fillPath:
          Paint _fillPaint = fillPaint..style = PaintingStyle.fill;
          Path _path = _drawToContext(drawing)..close();
          drawPath(_path, _fillPaint);
          break;
        case OpSetType.fillSketch:
          drawPath(_drawToContext(drawing), fillPaint);
          break;
      }
    }
  }
}
