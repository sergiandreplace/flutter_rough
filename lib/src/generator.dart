import 'package:rough/src/filler/line_filler.dart';
import 'package:rough/src/renderer.dart';

import 'core.dart';

class Generator {
  Drawable _d(String shape, List<OpSet> sets, Options options) {
    return Drawable(shape: shape, sets: sets ?? List<OpSet>(), options: options);
  }

  Drawable line(double x1, double y1, double x2, double y2, {Options options}) {
    final o = options ?? Options();
    return this._d('line', [buildLine(x1, y1, x2, y2, o)], o);
  }

  Drawable rectangle(double x, double y, double width, double height, {Options options}) {
    final o = options ?? Options();
    List<OpSet> paths = [];
    OpSet outline = buildRectangle(x, y, width, height, o);
//    if (o.fill) {
    List<PointD> points = [PointD(x, y), PointD(x + width, y), PointD(x + width, y + height), PointD(x, y + height)];
//      if (o.fillStyle === 'solid') {
//        paths.push(solidFillPolygon(points, o));
//      } else {
    paths.add(DotFiller().fill(points, o));
//      }
//    }
//if (o.stroke !== NOS) {
    paths.add(outline);
    return _d('rectangle', paths, o);
  }

  Drawable circle(double x, double y, double diameter, {Options options}) {
    Drawable ret = this.ellipse(x, y, diameter, diameter, options);
    ret.shape = 'circle';
    return ret;
  }

  Drawable ellipse(double x, double y, double width, double height, Options options) {
    final o = options ?? Options();
    List<OpSet> paths = [];
    EllipseParams ellipseParams = generateEllipseParams(width, height, o);
    EllipseResult ellipseResponse = ellipseWithParams(x, y, o, ellipseParams);
    if (o.fill != null) {
//      if (o.fillStyle == 'solid') {
//        OpSet shape = ellipseResponse.opset;
//        shape.type = OpSetType.fillPath;
//        paths.add(shape);
//      } else {
      paths.add(DotFiller().fill(ellipseResponse.estimatedPoints, o));
//      }
    }
    if (o.stroke != null) {
      paths.add(ellipseResponse.opset);
    }
    return _d('ellipse', paths, o);
  }
}

class ComputedEllipsePoints {
  List<PointD> corePoints;
  List<PointD> allPoints;

  ComputedEllipsePoints({this.corePoints, this.allPoints});
}

class EllipseParams {
  final double rx;
  final double ry;
  final double increment;

  EllipseParams({this.rx, this.ry, this.increment});
}

class EllipseResult {
  OpSet opset;
  List<PointD> estimatedPoints;

  EllipseResult({this.opset, this.estimatedPoints});
}
