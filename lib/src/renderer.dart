import 'dart:math';

import 'config.dart';
import 'core.dart';
import 'entities.dart';
import 'geometry.dart';

List<Op> _line(double x1, double y1, double x2, double y2, DrawConfig config, bool move, bool overlay) {
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
    EllipseParams params = generateEllipseParams(width, height, config);
    return ellipseWithParams(x, y, config, params).opset;
  }

  static OpSet buildPolygon(List<PointD> points, DrawConfig config) {
    return linearPath(points, true, config);
  }

  static OpSet linearPath(List<PointD> points, bool close, DrawConfig config) {
    int len = (points ?? []).length;
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
}

class OpsGenerator {
  static List<Op> doubleLine(double x1, double y1, double x2, double y2, DrawConfig config) {
    List<Op> o1 = _line(x1, y1, x2, y2, config, true, false);
    List<Op> o2 = _line(x1, y1, x2, y2, config, true, true);
    return o1 + o2;
  }

  static List<Op> curve(List<PointD> points, DrawConfig config) {
    int len = points.length;
    if (len > 3) {
      List<Op> ops = [];
      double s = 1 - config.curveTightness;
      ops.add(Op.move(points[1]));
      for (int i = 1; (i + 2) < len; i++) {
        final point = points[i];
        final next = points[i + 1];
        final afterNext = points[i + 2];
        var previous = points[i - 1];
        final control1 = PointD(point.x + (s * next.x - s * previous.x) / 6, point.y + (s * next.y - s * previous.y) / 6);
        final control2 = PointD(next.x + (s * point.x - s * afterNext.x) / 6, next.y + (s * point.y - s * afterNext.y) / 6);
        final end = PointD(next.x, next.y);
        ops.add(Op.curveTo(control1, control2, end));
        return ops;
      }
    } else if (len == 3) {
      return []..add(Op.move(points[1]))..add(Op.curveTo(points[1], points[2], points[2]));
    } else if (len == 2) {
      return doubleLine(points[0].x, points[0].y, points[1].x, points[1].y, config);
    }
    return [];
  }
}

EllipseParams generateEllipseParams(double width, double height, DrawConfig config) {
  double psq = sqrt(pi * 2 * sqrt((pow(width / 2, 2) + pow(height / 2, 2)) / 2));
  double stepCount = max(config.curveStepCount, (config.curveStepCount / sqrt(200)) * psq);
  double increment = (pi * 2) / stepCount;
  double rx = (width / 2).abs();
  double ry = (height / 2).abs();
  double curveFitRandomness = 1 - config.curveFitting;
  rx += config.offsetSymmetric(rx * curveFitRandomness);
  ry += config.offsetSymmetric(ry * curveFitRandomness);
  return EllipseParams(increment: increment, rx: rx, ry: ry);
}

EllipseResult ellipseWithParams(double x, double y, DrawConfig config, EllipseParams ellipseParams) {
  ComputedEllipsePoints ellipsePoints1 = _computeEllipsePoints(
    increment: ellipseParams.increment,
    cx: x,
    cy: y,
    rx: ellipseParams.rx,
    ry: ellipseParams.ry,
    offset: 1,
    overlap: ellipseParams.increment * config.offset(0.1, config.offset(0.4, 1)),
    config: config,
  );
  ComputedEllipsePoints ellipsePoints2 = _computeEllipsePoints(
    increment: ellipseParams.increment,
    cx: x,
    cy: y,
    rx: ellipseParams.rx,
    ry: ellipseParams.ry,
    offset: 1.5,
    overlap: 0,
    config: config,
  );
  List<Op> o1 = OpsGenerator.curve(ellipsePoints1.allPoints, config);
  List<Op> o2 = OpsGenerator.curve(ellipsePoints2.allPoints, config);
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
  DrawConfig config,
}) {
  List<PointD> corePoints = [];
  List<PointD> allPoints = [];
  double radOffset = config.offsetSymmetric(0.5) - pi / 2;
  allPoints.add(PointD(
    config.offsetSymmetric(offset) + cx + 0.9 * rx * cos(radOffset - increment),
    config.offsetSymmetric(offset) + cy + 0.9 * ry * sin(radOffset - increment),
  ));
  for (double angle = radOffset; angle < (pi * 2 + radOffset - 0.01); angle = angle + increment) {
    PointD p = PointD(
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
