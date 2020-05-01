import 'dart:math';

import 'package:rough/src/filler/hachure_filler.dart';
import 'package:rough/src/geometry.dart';
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
    paths.add(HachureFiller().fillPolygon(points, o));
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
      if (o.fillStyle == 'solid') {
        OpSet shape = ellipseResponse.opset;
        shape.type = OpSetType.fillPath;
        paths.add(shape);
      } else {
        paths.add(HachureFiller().fillPolygon(ellipseResponse.estimatedPoints, o));
      }
    }
    if (o.stroke != null) {
      paths.add(ellipseResponse.opset);
    }
    return _d('ellipse', paths, o);
  }

  EllipseParams generateEllipseParams(double width, double height, Options o) {
    double psq = sqrt(pi * 2 * sqrt((pow(width / 2, 2) + pow(height / 2, 2)) / 2));
    double stepCount = max(o.curveStepCount, (o.curveStepCount / sqrt(200)) * psq);
    double increment = (pi * 2) / stepCount;
    double rx = (width / 2).abs();
    double ry = (height / 2).abs();
    double curveFitRandomness = 1 - o.curveFitting;
    rx += offsetOpt(rx * curveFitRandomness, o, 1);
    ry += offsetOpt(ry * curveFitRandomness, o, 1);
    return EllipseParams(increment: increment, rx: rx, ry: ry);
  }

  EllipseResult ellipseWithParams(double x, double y, Options o, EllipseParams ellipseParams) {
    ComputedEllipsePoints ellipsePoints1 = _computeEllipsePoints(
      increment: ellipseParams.increment,
      cx: x,
      cy: y,
      rx: ellipseParams.rx,
      ry: ellipseParams.ry,
      offset: 1,
      overlap: ellipseParams.increment * offset(0.1, offset(0.4, 1, o, 1), o, 1),
      o: o,
    );
    ComputedEllipsePoints ellipsePoints2 = _computeEllipsePoints(
      increment: ellipseParams.increment,
      cx: x,
      cy: y,
      rx: ellipseParams.rx,
      ry: ellipseParams.ry,
      offset: 1.5,
      overlap: 0,
      o: o,
    );
    List<Op> o1 = curve(ellipsePoints1.allPoints, null, o);
    List<Op> o2 = curve(ellipsePoints2.allPoints, null, o);
    return EllipseResult(estimatedPoints: ellipsePoints1.corePoints, opset: OpSet(type: OpSetType.path, ops: o1 + o2));
  }

  ComputedEllipsePoints _computeEllipsePoints({
    double increment,
    double cx,
    double cy,
    double rx,
    double ry,
    double offset,
    double overlap,
    Options o,
  }) {
    List<PointD> corePoints = [];
    List<PointD> allPoints = [];
    double radOffset = offsetOpt(0.5, o, 1) - pi / 2;
    allPoints.add(PointD(
      offsetOpt(offset, o, 1) + cx + 0.9 * rx + cos(radOffset - increment),
      offsetOpt(offset, o, 1) + cy + 0.9 * ry + sin(radOffset - increment),
    ));
    for (double angle = radOffset; angle < (pi * 2 + radOffset - 0.01); angle = angle + increment) {
      PointD p = PointD(
        offsetOpt(offset, o, 1) + cx + rx * cos(angle),
        offsetOpt(offset, o, 1) + cy + ry * sin(angle),
      );
      allPoints.add(p);
      corePoints.add(p);
    }
    allPoints.add(PointD(
      offsetOpt(offset, o, 1) + cx + rx * cos(radOffset + pi * 2 + overlap * 0.5),
      offsetOpt(offset, o, 1) + cy + ry * sin(radOffset + pi * 2 + overlap * 0.5),
    ));
    allPoints.add(PointD(
      offsetOpt(offset, o, 1) + cx + 0.98 * rx * cos(radOffset + overlap),
      offsetOpt(offset, o, 1) + cy + 0.98 * ry * sin(radOffset + overlap),
    ));
    allPoints.add(PointD(
      offsetOpt(offset, o, 1) + cx + 0.9 * rx * cos(radOffset + overlap * 0.5),
      offsetOpt(offset, o, 1) + cy + 0.9 * ry * sin(radOffset + overlap * 0.5),
    ));
    return ComputedEllipsePoints(corePoints: corePoints, allPoints: allPoints);
  }
}

List<Op> curve(List<PointD> points, PointD closePoint, Options o) {
  int len = points.length;
  List<Op> ops = [];
  if (len > 3) {
    List<PointD> b = List<PointD>(4);
    double s = 1 - o.curveTightness;
    ops.add(Op(OpType.move, [points[1].x, points[1].y]));
    for (int i = 1; (i + 2) < len; i++) {
      PointD cachedVertArray = points[i];
      b[0] = PointD(cachedVertArray.x, cachedVertArray.y);
      b[1] = PointD(cachedVertArray.x + (s * points[i + 1].x - s * points[i - 1].x) / 6,
          cachedVertArray.y + (s * points[i + 1].y - s * points[i - 1].y) / 6);
      b[2] = PointD(
          points[i + 1].x + (s * points[i].x - s * points[i + 2].x) / 6, points[i + 1].y + (s * points[i].y - s * points[i + 2].y) / 6);
      b[3] = PointD(points[i + 1].x, points[i + 1].y);
      ops.add(Op(OpType.bCurveTo, [b[1].x, b[1].y, b[2].x, b[2].y, b[3].x, b[3].y]));
    }
    if (closePoint != null) {
      double ro = o.maxRandomnessOffset;
      ops.add(Op(OpType.lineTo, [closePoint.x + offsetOpt(ro, o, 1), closePoint.y + offsetOpt(ro, o, 1)]));
    }
  } else if (len == 3) {
    ops.add(Op(OpType.move, [points[1].x, points[1].y]));
    ops.add(Op(OpType.bCurveTo, [points[1].x, points[1].y, points[2].x, points[2].y, points[2].x, points[2].y]));
  } else if (len == 2) {
    ops = doubleLine(points[0].x, points[0].y, points[1].x, points[1].y, o);
  }
  return ops;
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

class PointD extends Point<double> {
  PointD(double x, double y) : super(x, y);

  bool isInPolygon(List<Point> points) {
    int vertices = points.length;

    // There must be at least 3 vertices in polygon
    if (vertices < 3) {
      return false;
    }
    Point extreme = Point(double.maxFinite, y);
    int count = 0;
    for (int i = 0; i < vertices; i++) {
      Point current = points[i];
      Point next = points[(i + 1) % vertices];
      if (Line(current, next).intersects(Line(this, extreme))) {
        if (getOrientation(current, this, next) == Orient.collinear) {
          return Line(current, next).onSegment(this);
        }
        count++;
      }
    }
    // true if count is off
    return count % 2 == 1;
  }

  @override
  String toString() {
    return 'PointD{x:$x, y:$y}';
  }
}
