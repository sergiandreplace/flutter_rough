import 'dart:math';

import 'config.dart';
import 'core.dart';
import 'geometry.dart';

class Drawable {
  String shape;
  DrawConfig options;
  List<OpSet> sets;

  Drawable({this.shape, this.options, this.sets});
}

class PointD extends Point<double> {
  PointD(double x, double y) : super(x, y);

  bool isInPolygon(List<PointD> points) {
    int vertices = points.length;

    // There must be at least 3 vertices in polygon
    if (vertices < 3) {
      return false;
    }
    PointD extreme = PointD(double.maxFinite, y);
    int count = 0;
    for (int i = 0; i < vertices; i++) {
      PointD current = points[i];
      PointD next = points[(i + 1) % vertices];
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
