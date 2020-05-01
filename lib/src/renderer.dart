import 'dart:math';

import 'package:rough/src/core.dart';

import 'generator.dart';

List<Op> _line(double x1, double y1, double x2, double y2, Options o, bool move, bool overlay) {
  final lengthSq = pow((x1 - x2), 2) + pow((y1 - y2), 2);
  final length = sqrt(lengthSq);
  double roughnessGain;

  if (length < 200) {
    roughnessGain = 1;
  } else if (length > 500) {
    roughnessGain = 0.4;
  } else {
    roughnessGain = (-0.0016668) * length + 1.233334;
  }

  double offset = o.maxRandomnessOffset;
  if ((offset * offset * 100) > lengthSq) {
    offset = length / 10;
  }

  final halfOffset = offset / 2;
  final divergePoint = 0.2 + o.randomizer.next() * 0.2;

  double midDispX = o.bowing * o.maxRandomnessOffset * (y2 - y1) / 200;
  double midDispY = o.bowing * o.maxRandomnessOffset * (x1 - x2) / 200;
  midDispX = offsetOpt(midDispX, o, roughnessGain);
  midDispY = offsetOpt(midDispY, o, roughnessGain);

  final ops = List<Op>();
  final randomHalf = () => offsetOpt(halfOffset, o, roughnessGain);
  final randomFull = () => offsetOpt(offset, o, roughnessGain);

  if (move) {
    if (overlay) {
      ops.add(Op(OpType.move, [x1 + randomHalf(), y1 + randomHalf()]));
    } else {
      ops.add(Op(OpType.move, [x1 + offsetOpt(offset, o, roughnessGain), y1 + offsetOpt(offset, o, roughnessGain)]));
    }
  }
  if (overlay) {
    ops.add(Op(OpType.bCurveTo, [
      midDispX + x1 + (x2 - x1) * divergePoint + randomHalf(),
      midDispY + y1 + (y2 - y1) * divergePoint + randomHalf(),
      midDispX + x1 + 2 * (x2 - x1) * divergePoint + randomHalf(),
      midDispY + y1 + 2 * (y2 - y1) * divergePoint + randomHalf(),
      x2 + randomHalf(),
      y2 + randomHalf()
    ]));
  } else {
    ops.add(Op(OpType.bCurveTo, [
      midDispX + x1 + (x2 - x1) * divergePoint + randomFull(),
      midDispY + y1 + (y2 - y1) * divergePoint + randomFull(),
      midDispX + x1 + 2 * (x2 - x1) * divergePoint + randomFull(),
      midDispY + y1 + 2 * (y2 - y1) * divergePoint + randomFull(),
      x2 + randomFull(),
      y2 + randomFull()
    ]));
  }
  return ops;
}

double offset(double min, double max, Options ops, double roughnessGain) {
  return ops.roughness * roughnessGain * ((ops.randomizer.next() * (max - min)) + min);
}

double offsetOpt(double x, Options ops, double roughnessGain) {
  return offset(-x, x, ops, roughnessGain);
}

OpSet buildLine(double x1, double y1, double x2, double y2, Options options) {
  return OpSet(type: OpSetType.path, ops: doubleLine(x1, y1, x2, y2, options));
}

OpSet buildRectangle(double x, double y, double width, double height, Options options) {
  List<PointD> points = [PointD(x, y), PointD(x + width, y), PointD(x + width, y + height), PointD(x, y + height)];
  return polygon(points, options);
}

List<Op> doubleLine(double x1, double y1, double x2, double y2, Options options) {
  List<Op> o1 = _line(x1, y1, x2, y2, options, true, false);
  List<Op> o2 = _line(x1, y1, x2, y2, options, true, true);
  return o1 + o2;
}

OpSet polygon(List<PointD> points, Options options) {
  return linearPath(points, true, options);
}

OpSet linearPath(List<PointD> points, bool close, Options options) {
  int len = (points ?? []).length;
  if (len > 2) {
    List<Op> ops = [];
    for (int i = 0; i < len - 1; i++) {
      ops += doubleLine(points[i].x, points[i].y, points[i + 1].x, points[i + 1].y, options);
    }
    if (close) {
      ops += doubleLine(points[len - 1].x, points[len - 1].y, points[0].x, points[0].y, options);
    }
    return OpSet(type: OpSetType.path, ops: ops);
  } else if (len == 2) {
    return buildLine(points[0].x, points[0].x, points[1].x, points[1].x, options);
  } else {
    return OpSet(type: OpSetType.path, ops: []);
  }
}

OpSet ellipse(double x, double y, double width, double height, Options o) {
  EllipseParams params = generateEllipseParams(width, height, o);
  return ellipseWithParams(x, y, o, params).opset;
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
