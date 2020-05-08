import 'dart:math';

import 'config.dart';
import 'core.dart';
import 'entities.dart';
import 'geometry.dart';

List<Op> _line(double x1, double y1, double x2, double y2, DrawConfig config, bool move, bool overlay) {
  final lengthSq = pow(x1 - x2, 2) + pow(y1 - y2, 2);
  final length = sqrt(lengthSq);
  double roughnessGain;

  if (length < 200) {
    roughnessGain = 1;
  } else if (length > 500) {
    roughnessGain = 0.4;
  } else {
    roughnessGain = (-0.0016668) * length + 1.233334;
  }

  double offset = config.maxRandomnessOffset;
  if ((offset * offset * 100) > lengthSq) {
    offset = length / 10;
  }

  final halfOffset = offset / 2;
  final divergePoint = 0.2 + config.randomizer.next() * 0.2;

  double offsetX = config.bowing * config.maxRandomnessOffset * (y2 - y1) / 200;
  double offsetY = config.bowing * config.maxRandomnessOffset * (x1 - x2) / 200;
  offsetX = config.offsetSymmetric(offsetX, roughnessGain);
  offsetY = config.offsetSymmetric(offsetY, roughnessGain);

  final ops = <Op>[];
  final randomHalf = () => config.offsetSymmetric(halfOffset, roughnessGain);
  final randomFull = () => config.offsetSymmetric(offset, roughnessGain);

  if (move) {
    if (overlay) {
      ops.add(Op.move(PointD(x1 + randomHalf(), y1 + randomHalf())));
    } else {
      ops.add(Op.move(PointD(x1 + config.offsetSymmetric(offset, roughnessGain), y1 + config.offsetSymmetric(offset, roughnessGain))));
    }
  }
  if (overlay) {
    ops.add(
      Op.curveTo(
        PointD(
          offsetX + x1 + (x2 - x1) * divergePoint + randomHalf(),
          offsetY + y1 + (y2 - y1) * divergePoint + randomHalf(),
        ),
        PointD(
          offsetX + x1 + 2 * (x2 - x1) * divergePoint + randomHalf(),
          offsetY + y1 + 2 * (y2 - y1) * divergePoint + randomHalf(),
        ),
        PointD(
          x2 + randomHalf(),
          y2 + randomHalf(),
        ),
      ),
    );
  } else {
    ops.add(
      Op.curveTo(
        PointD(
          offsetX + x1 + (x2 - x1) * divergePoint + randomFull(),
          offsetY + y1 + (y2 - y1) * divergePoint + randomFull(),
        ),
        PointD(
          offsetX + x1 + 2 * (x2 - x1) * divergePoint + randomFull(),
          offsetY + y1 + 2 * (y2 - y1) * divergePoint + randomFull(),
        ),
        PointD(
          x2 + randomFull(),
          y2 + randomFull(),
        ),
      ),
    );
  }
  return ops;
}

class OpSetBuilder {
  static OpSet buildLine(double x1, double y1, double x2, double y2, DrawConfig config) {
    return OpSet(type: OpSetType.path, ops: OpsGenerator.doubleLine(x1, y1, x2, y2, config));
  }

  static OpSet ellipse(double x, double y, double width, double height, DrawConfig config) {
    final EllipseParams params = generateEllipseParams(width, height, config);
    return ellipseWithParams(x, y, config, params).opSet;
  }

  static OpSet buildPolygon(List<PointD> points, DrawConfig config) {
    return linearPath(points, true, config);
  }

  static OpSet linearPath(List<PointD> points, bool close, DrawConfig config) {
    final int len = (points ?? []).length;
    if (len > 2) {
      List<Op> ops = [];
      for (int i = 0; i < len - 1; i++) {
        ops += OpsGenerator.doubleLine(points[i].x, points[i].y, points[i + 1].x, points[i + 1].y, config);
      }
      if (close) {
        ops += OpsGenerator.doubleLine(points[len - 1].x, points[len - 1].y, points[0].x, points[0].y, config);
      }
      return OpSet(type: OpSetType.path, ops: ops);
    } else if (len == 2) {
      return buildLine(points[0].x, points[0].x, points[1].x, points[1].x, config);
    } else {
      return OpSet(type: OpSetType.path, ops: []);
    }
  }

  static OpSet arc(
      PointD center, double width, double height, double start, double stop, bool closed, bool roughClosure, DrawConfig config) {
    final List<Op> ops = [];
    final double cx = center.x;
    final double cy = center.y;
    double rx = (width / 2).abs();
    double ry = (height / 2).abs();
    rx += config.offsetSymmetric(rx * 0.01);
    ry += config.offsetSymmetric(ry * 0.01);
    double strt = start;
    double stp = stop;
    while (strt < 0) {
      strt += pi * 2;
      stp += pi * 2;
    }
    if ((stp - strt) > (pi * 2)) {
      strt = 0;
      stp = pi * 2;
    }
    final double ellipseInc = pi * 2 / config.curveStepCount;
    final double arcIn = min(ellipseInc / 2, (stp - strt) / 2);
    ops
      ..addAll(OpsGenerator.arc(arcIn, cx, cy, rx, ry, strt, stp, 1, config))
      ..addAll(OpsGenerator.arc(arcIn, cx, cy, rx, ry, strt, stp, 1.5, config));
    if (closed) {
      if (roughClosure) {
        ops
          ..addAll(OpsGenerator.doubleLine(cx, cy, cx + rx * cos(strt), cy + ry * sin(strt), config))
          ..addAll(OpsGenerator.doubleLine(cx, cy, cx + rx * cos(stp), cy + ry * sin(stp), config));
      } else {
        ops..add(Op.lineTo(PointD(cx, cy)))..add(Op.lineTo(PointD(cx + rx * cos(strt), cy + ry * sin(strt))));
      }
    }
    return OpSet(type: OpSetType.path, ops: ops);
  }

  static List<PointD> arcPolygon(PointD center, double width, double height, double startAngle, double stopAngle, DrawConfig config) {
    double radiusX = (width / 2).abs();
    double radiusY = (height / 2).abs();
    radiusX += config.offsetSymmetric(radiusX * 0.01);
    radiusY += config.offsetSymmetric(radiusY * 0.01);
    double start = startAngle;
    double stop = stopAngle;
    while (start < 0) {
      start += pi * 2;
      stop += pi * 2;
    }
    if ((stop - start) > (pi * 2)) {
      start = 0;
      stop = pi * 2;
    }
    final double ellipseInc = pi * 2 / config.curveStepCount;
    final double increment = min(ellipseInc / 2, (stop - start) / 2);
    //final double increment = (stop - start) / (config.curveStepCount * 2);
    final List<PointD> points = [];
    for (double angle = start; angle <= stop; angle = angle + increment) {
      points.add(PointD(center.x + radiusX * cos(angle), center.y + radiusY * sin(angle)));
    }
    points..add(PointD(center.x + radiusX * cos(stop), center.y + radiusY * sin(stop)))..add(center);
    return points;
  }

  static OpSet curve(List<PointD> points, DrawConfig config) {
    final List<Op> op1 = OpsGenerator.curveWithOffset(points, 1 * (1 + config.roughness * 0.2), config);
    final List<Op> op2 = OpsGenerator.curveWithOffset(points, 1.5 * (1 + config.roughness * 0.2), config);
    return OpSet(type: OpSetType.path, ops: op1 + op2);
  }
}

class OpsGenerator {
  static List<Op> doubleLine(double x1, double y1, double x2, double y2, DrawConfig config) {
    final List<Op> o1 = _line(x1, y1, x2, y2, config, true, false);
    final List<Op> o2 = _line(x1, y1, x2, y2, config, true, true);
    return o1 + o2;
  }

  static List<Op> curve(List<PointD> points, DrawConfig config) {
    final int len = points.length;
    if (len > 3) {
      final List<Op> ops = [];
      final double s = 1 - config.curveTightness;
      ops.add(Op.move(points[1]));
      for (int i = 1; (i + 2) < len; i++) {
        final point = points[i];
        final next = points[i + 1];
        final afterNext = points[i + 2];
        final PointD previous = points[i - 1];
        final control1 = PointD(point.x + (s * next.x - s * previous.x) / 6, point.y + (s * next.y - s * previous.y) / 6);
        final control2 = PointD(next.x + (s * point.x - s * afterNext.x) / 6, next.y + (s * point.y - s * afterNext.y) / 6);
        final end = PointD(next.x, next.y);
        ops.add(Op.curveTo(control1, control2, end));
      }
      return ops;
    } else if (len == 3) {
      return [Op.move(points[1]), Op.curveTo(points[1], points[2], points[2])];
    } else if (len == 2) {
      return doubleLine(points[0].x, points[0].y, points[1].x, points[1].y, config);
    }
    return [];
  }

  static List<Op> curveWithOffset(List<PointD> points, double offset, DrawConfig config) {
    final List<PointD> result = [
      PointD(
        points.first.x + config.offsetSymmetric(offset),
        points.first.y + config.offsetSymmetric(offset),
      ),
      ...points.map((point) => PointD(
            point.x + config.offsetSymmetric(offset),
            point.y + config.offsetSymmetric(offset),
          )),
      PointD(
        points.last.x + config.offsetSymmetric(offset),
        points.last.y + config.offsetSymmetric(offset),
      )
    ];
    return curve(result, config);
  }

  static List<Op> arc(
      double increment, double cx, double cy, double rx, double ry, double strt, double stp, double offset, DrawConfig config) {
    final List<PointD> points = [];
    final double radOffset = strt + config.offsetSymmetric(0.1);
    points.add(PointD(
      config.offsetSymmetric(offset) + cx + 0.9 * rx * cos(radOffset - increment),
      config.offsetSymmetric(offset) + cy + 0.9 * ry * sin(radOffset - increment),
    ));
    for (double angle = radOffset; angle <= stp; angle += increment) {
      points.add(PointD(
        config.offsetSymmetric(offset) + cx + rx * cos(angle),
        config.offsetSymmetric(offset) + cy + ry * sin(angle),
      ));
    }
    points..add(PointD(cx + rx * cos(stp), cy + ry * sin(stp)))..add(PointD(cx + rx * cos(stp), cy + ry * sin(stp)));
    return curve(points, config);
  }
}

EllipseParams generateEllipseParams(double width, double height, DrawConfig config) {
  final double psq = sqrt(pi * 2 * sqrt((pow(width / 2, 2) + pow(height / 2, 2)) / 2));
  final double stepCount = max(config.curveStepCount, (config.curveStepCount / sqrt(200)) * psq);
  final double increment = (pi * 2) / stepCount;
  final double curveFitRandomness = 1 - config.curveFitting;

  double rx = (width / 2).abs();
  double ry = (height / 2).abs();
  rx += config.offsetSymmetric(rx * curveFitRandomness);
  ry += config.offsetSymmetric(ry * curveFitRandomness);

  return EllipseParams(increment: increment, rx: rx, ry: ry);
}

EllipseResult ellipseWithParams(double x, double y, DrawConfig config, EllipseParams ellipseParams) {
  final ComputedEllipsePoints ellipsePoints1 = _computeEllipsePoints(
    increment: ellipseParams.increment,
    cx: x,
    cy: y,
    rx: ellipseParams.rx,
    ry: ellipseParams.ry,
    offset: 1,
    overlap: ellipseParams.increment * config.offset(0.1, config.offset(0.4, 1)),
    config: config,
  );
  final ComputedEllipsePoints ellipsePoints2 = _computeEllipsePoints(
    increment: ellipseParams.increment,
    cx: x,
    cy: y,
    rx: ellipseParams.rx,
    ry: ellipseParams.ry,
    offset: 1.5,
    overlap: 0,
    config: config,
  );
  final List<Op> o1 = OpsGenerator.curve(ellipsePoints1.allPoints, config);
  final List<Op> o2 = OpsGenerator.curve(ellipsePoints2.allPoints, config);
  return EllipseResult(estimatedPoints: ellipsePoints1.corePoints, opSet: OpSet(type: OpSetType.path, ops: o1 + o2));
}

ComputedEllipsePoints _computeEllipsePoints({
  double increment,
  double cx,
  double cy,
  double rx,
  double ry,
  double offset,
  double overlap,
  DrawConfig config,
}) {
  final List<PointD> corePoints = [];
  final List<PointD> allPoints = [];
  final double radOffset = config.offsetSymmetric(0.5) - pi / 2;
  allPoints.add(PointD(
    config.offsetSymmetric(offset) + cx + 0.9 * rx * cos(radOffset - increment),
    config.offsetSymmetric(offset) + cy + 0.9 * ry * sin(radOffset - increment),
  ));
  for (double angle = radOffset; angle < (pi * 2 + radOffset - 0.01); angle = angle + increment) {
    final PointD p = PointD(
      config.offsetSymmetric(offset) + cx + rx * cos(angle),
      config.offsetSymmetric(offset) + cy + ry * sin(angle),
    );
    allPoints.add(p);
    corePoints.add(p);
  }
  allPoints
    ..add(PointD(
      config.offsetSymmetric(offset) + cx + rx * cos(radOffset + pi * 2 + overlap * 0.5),
      config.offsetSymmetric(offset) + cy + ry * sin(radOffset + pi * 2 + overlap * 0.5),
    ))
    ..add(PointD(
      config.offsetSymmetric(offset) + cx + 0.98 * rx * cos(radOffset + overlap),
      config.offsetSymmetric(offset) + cy + 0.98 * ry * sin(radOffset + overlap),
    ))
    ..add(PointD(
      config.offsetSymmetric(offset) + cx + 0.9 * rx * cos(radOffset + overlap * 0.5),
      config.offsetSymmetric(offset) + cy + 0.9 * ry * sin(radOffset + overlap * 0.5),
    ));
  return ComputedEllipsePoints(corePoints: corePoints, allPoints: allPoints);
}
