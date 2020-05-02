import 'dart:math';

import 'package:rough/src/config.dart';

import 'geometry.dart';

class Op {
  final OpType op;
  final List<Point> data;

  Op._(this.op, this.data);

  Op.move(Point point)
      : this.op = OpType.move,
        this.data = [point];

  Op.lineTo(Point point)
      : this.op = OpType.lineTo,
        this.data = [point];

  Op.curveTo(Point control1, Point control2, Point destination)
      : this.op = OpType.curveTo,
        this.data = [control1, control2, destination];
}

class OpSet {
  OpSetType type;
  List<Op> ops;

  OpSet({this.type, this.ops});
}

class Drawable {
  String shape;
  DrawConfig options;
  List<OpSet> sets;

  Drawable({this.shape, this.options, this.sets});
}

enum OpType { move, curveTo, lineTo }
enum OpSetType { path, fillPath, fillSketch }

class Line {
  PointD source;
  PointD target;

  Line(this.source, this.target);

  get length => sqrt(pow(source.x - target.x, 2) + pow(source.y - target.y, 2));

  bool onSegment(PointD point) => (point.x <= max(source.x, target.x) &&
      point.x >= min(source.x, target.x) &&
      point.y <= max(source.y, target.y) &&
      point.y >= min(source.y, target.y));

  bool intersects(Line line) {
    PointsOrientation o1 = getOrientation(source, target, line.source);
    PointsOrientation o2 = getOrientation(source, target, line.target);
    PointsOrientation o3 = getOrientation(line.source, line.target, source);
    PointsOrientation o4 = getOrientation(line.source, line.target, target);

    if (o1 != o2 && o3 != o4) {
      return true;
    }
    // source, target and line.source are colinear and line.source lies on segment this.source-this.target

    if (o1 == PointsOrientation.collinear && onSegmentPoints(this.source, line.source, this.target)) {
      return true;
    }

    // this.source, this.target and line.source are collinear and line.target lies on segment this.source-this.target
    if (o2 == PointsOrientation.collinear && onSegmentPoints(this.source, line.target, this.target)) {
      return true;
    }

    // line.source, line.target and this.source are collinear and this.source lies on segment line.source-line.target
    if (o3 == PointsOrientation.collinear && onSegmentPoints(line.source, this.source, line.target)) {
      return true;
    }

    // line.source, line.target and this.target are collinear and this.target lies on segment line.source-line.target
    if (o4 == PointsOrientation.collinear && onSegmentPoints(line.source, this.target, line.target)) {
      return true;
    }
    return false;
  }

  PointD intersectionWith(Line line) {
    double yDiff = target.y - source.y;
    double xDiff = source.x - target.x;
    double diff = yDiff * (source.x) + xDiff * (source.y);
    double lineYDiff = line.target.y - line.source.y;
    double lineXDiff = line.source.x - line.target.x;
    double lineDiff = lineYDiff * (line.source.x) + lineXDiff * (line.source.y);
    double determinant = yDiff * lineXDiff - lineYDiff * xDiff;
    return determinant == 0
        ? PointD((lineXDiff * diff - xDiff * lineDiff) / determinant, (yDiff * lineDiff - lineYDiff * diff) / determinant)
        : null;
  }

  bool isMidPointInPolygon(List<Point> polygon) {
    return PointD((source.x + target.x) / 2, (source.y + target.y) / 2).isInPolygon(polygon);
  }
}

class PointD extends Point<double> {
  PointD(double x, double y) : super(x, y);

  bool isInPolygon(List<Point> points) {
    int vertices = points.length;

    // There must be at least 3 vertices in polygon
    if (vertices < 3) {
      return false;
    }
    PointD extreme = PointD(double.maxFinite, y);
    int count = 0;
    for (int i = 0; i < vertices; i++) {
      Point current = points[i];
      Point next = points[(i + 1) % vertices];
      if (Line(current, next).intersects(Line(this, extreme))) {
        if (getOrientation(current, this, next) == PointsOrientation.collinear) {
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
