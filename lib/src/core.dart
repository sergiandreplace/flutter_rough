import 'dart:math';

import 'entities.dart';
import 'geometry.dart';

class Op {
  final OpType op;
  final List<PointD> data;

  Op.move(PointD point)
      : op = OpType.move,
        data = [point];

  Op.lineTo(PointD point)
      : op = OpType.lineTo,
        data = [point];

  Op.curveTo(PointD control1, PointD control2, PointD destination)
      : op = OpType.curveTo,
        data = [control1, control2, destination];
}

class OpSet {
  OpSetType type;
  List<Op> ops;

  OpSet({this.type, this.ops});
}

enum OpType { move, curveTo, lineTo }
enum OpSetType { path, fillPath, fillSketch }

class Line {
  PointD source;
  PointD target;

  Line(this.source, this.target);

  double get length => sqrt(pow(source.x - target.x, 2) + pow(source.y - target.y, 2));

  bool onSegment(PointD point) =>
      point.x <= max(source.x, target.x) &&
      point.x >= min(source.x, target.x) &&
      point.y <= max(source.y, target.y) &&
      point.y >= min(source.y, target.y);

  bool intersects(Line line) {
    final PointsOrientation o1 = getOrientation(source, target, line.source);
    final PointsOrientation o2 = getOrientation(source, target, line.target);
    final PointsOrientation o3 = getOrientation(line.source, line.target, source);
    final PointsOrientation o4 = getOrientation(line.source, line.target, target);

    if (o1 != o2 && o3 != o4) {
      return true;
    }
    // source, target and line.source are colinear and line.source lies on segment this.source-this.target

    if (o1 == PointsOrientation.collinear && onSegmentPoints(source, line.source, target)) {
      return true;
    }

    // source, target and line.source are collinear and line.target lies on segment source-target
    if (o2 == PointsOrientation.collinear && onSegmentPoints(source, line.target, target)) {
      return true;
    }

    // line.source, line.target and source are collinear and source lies on segment line.source-line.target
    if (o3 == PointsOrientation.collinear && onSegmentPoints(line.source, source, line.target)) {
      return true;
    }

    // line.source, line.target and target are collinear and target lies on segment line.source-line.target
    if (o4 == PointsOrientation.collinear && onSegmentPoints(line.source, target, line.target)) {
      return true;
    }
    return false;
  }

  PointD intersectionWith(Line line) {
    final double yDiff = target.y - source.y;
    final double xDiff = source.x - target.x;
    final double diff = yDiff * (source.x) + xDiff * (source.y);
    final double lineYDiff = line.target.y - line.source.y;
    final double lineXDiff = line.source.x - line.target.x;
    final double lineDiff = lineYDiff * (line.source.x) + lineXDiff * (line.source.y);
    final double determinant = yDiff * lineXDiff - lineYDiff * xDiff;
    return determinant == 0
        ? PointD((lineXDiff * diff - xDiff * lineDiff) / determinant, (yDiff * lineDiff - lineYDiff * diff) / determinant)
        : null;
  }

  bool isMidPointInPolygon(List<PointD> polygon) {
    return PointD((source.x + target.x) / 2, (source.y + target.y) / 2).isInPolygon(polygon);
  }
}
