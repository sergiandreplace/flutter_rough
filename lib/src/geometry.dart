import 'dart:math';

import 'package:rough/src/core.dart';

List<PointD> rotatePoints(List<PointD> points, PointD center, double degrees) {
  if (points != null && points.isNotEmpty) {
    return points.map((p) => rotatePoint(p, center, degrees)).toList();
  } else {
    return [];
  }
}

PointD rotatePoint(PointD point, PointD center, double degrees) {
  double angle = (pi / 180) * degrees;
  double angleCos = cos(angle);
  double angleSin = sin(angle);

  return PointD(
    ((point.x - center.x) * angleCos) - ((point.y - center.y) * angleSin) + center.x,
    ((point.x - center.x) * angleSin) + ((point.y - center.y) * angleCos) + center.y,
  );
}

List<Line> rotateLines(List<Line> lines, PointD center, double degrees) =>
    lines.map((line) => Line(rotatePoint(line.source, center, degrees), rotatePoint(line.target, center, degrees))).toList();

enum Orient { collinear, clockwise, counterclockwise }

Orient getOrientation(PointD p, PointD q, PointD r) {
  double val = (q.x - p.x) * (r.y - q.y) - (q.y - p.y) * (r.x - q.x);
  if (val == 0) {
    return Orient.collinear;
  }
  return val > 0 ? Orient.clockwise : Orient.counterclockwise;
}

bool onSegmentPoints(PointD source, PointD point, PointD target) => Line(source, target).onSegment(point);

extension IterableOperations on Iterable<double> {
  double get max => reduce((curr, next) => curr > next ? curr : next);

  double get min => reduce((curr, next) => curr < next ? curr : next);
}
