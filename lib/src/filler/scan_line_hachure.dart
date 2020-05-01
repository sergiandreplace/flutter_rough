import 'dart:math';

import '../core.dart';
import '../generator.dart';
import '../geometry.dart';

List<Line> polygonHachureLines(List<PointD> points, Options o) {
  PointD rotationCenter = getCenter(points);
  double angle = (o.hachureAngle + 90).roundToDouble();
  if (angle != 0) {
    points = rotatePoints(points, rotationCenter, angle);
  }
  List<Line> lines = straightHachureLines(points, o);
  if (angle != 0) {
    lines = rotateLines(lines, rotationCenter, -angle);
  }
  return lines;
}

PointD getCenter(List<PointD> points) {
  double maxX = points.map((point) => point.x).max;
  double maxY = points.map((point) => point.y).max;
  double minX = points.map((point) => point.x).min;
  double minY = points.map((point) => point.x).min;
  return PointD((maxX + minX) / 2, (maxY + minY) / 2);
}

List<Line> straightHachureLines(List<PointD> points, Options o) {
  List<PointD> vertices = points ?? [];
  List<Line> lines = [];
  if (vertices[0] != vertices[vertices.length - 1]) {
    vertices.add(vertices[0]);
  }
  if (vertices.length > 2) {
    double gap = o.hachureGap;
    if (gap < 0) {
      gap = o.strokeWidth * 4;
    }
    gap = max(gap, 0.1);

    // Create sorted edges table
    List<Edge> edges = [];
    for (int i = 0; i < vertices.length - 1; i++) {
      PointD p1 = vertices[i];
      PointD p2 = vertices[i + 1];
      if (p1.x != p2.x) {
        double yMin = min(p1.y, p2.y);
        edges.add(Edge(yMin: yMin, yMax: max(p1.y, p2.y), x: yMin == p1.y ? p1.x : p2.x, isLope: (p2.x - p1.x) / (p2.y - p1.y)));
      }
    }
    edges.sort((e1, e2) {
      if (e1.yMin < e2.yMin) {
        return -1;
      } else if (e1.yMin > e2.yMin) {
        return 1;
      } else if (e1.x < e2.x) {
        return -1;
      } else if (e1.x > e2.x) {
        return 1;
      } else if (e1.yMax == e2.yMax) {
        return 0;
      } else {
        return ((e1.yMax - e2.yMax) / ((e1.yMax - e2.yMax).abs())).ceil();
      }
    });
    if (edges.isEmpty) {
      return lines;
    }
    // Start scanning
    List<ActiveEdge> activeEdges = [];
    double y = edges[0].yMin;
    while (activeEdges.isNotEmpty || edges.isNotEmpty) {
      if (edges.isNotEmpty) {
        int ix = -1;
        for (int i = 0; i < edges.length; i++) {
          if (edges[i].yMin > y) {
            break;
          }
          ix = i;
        }
        List<Edge> removed = edges.sublist(0, ix + 1);
        edges.removeRange(0, ix + 1);
        removed.forEach((edge) {
          activeEdges.add(ActiveEdge(y, edge));
        });
      }
      activeEdges = activeEdges.where((ae) => ae.edge.yMax > y).toList();
      activeEdges.sort((ae1, ae2) {
        if (ae1.edge.x == ae2.edge.x) {
          return 0;
        }
        return ((ae1.edge.x - ae2.edge.x) / ((ae1.edge.x - ae2.edge.x)).abs()).ceil();
      });

      // fill between the edges
      if (activeEdges.length > 1) {
        for (int i = 0; i < activeEdges.length; i = i + 2) {
          int nexti = i + 1;
          if (nexti >= activeEdges.length) {
            break;
          }
          Edge ce = activeEdges[i].edge;
          Edge ne = activeEdges[nexti].edge;
          lines.add(Line(PointD(ce.x.roundToDouble(), y), PointD(ne.x.roundToDouble(), y)));
        }
      }

      y += gap;
      activeEdges = activeEdges.map((ae) {
        return ActiveEdge(ae.s, ae.edge.copyWith(x: ae.edge.x + (gap * ae.edge.isLope)));
      }).toList();
    }
  }
  return lines;
}

class Edge {
  double yMin;
  double yMax;
  double x;
  double isLope;

  Edge({this.yMin, this.yMax, this.x, this.isLope});

  Edge copyWith({double yMin, double yMax, double x, double isLope}) => Edge(
        yMin: yMin ?? this.yMin,
        yMax: yMax ?? this.yMax,
        x: x ?? this.x,
        isLope: isLope ?? this.isLope,
      );

  @override
  String toString() {
    return 'Edge{yMin: $yMin, yMax: $yMax, x: $x, isLope: $isLope}';
  }
}

class ActiveEdge {
  double s;
  Edge edge;

  ActiveEdge(this.s, this.edge);
}
