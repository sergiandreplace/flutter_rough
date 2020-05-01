import 'dart:math';

import '../core.dart';
import '../geometry.dart';
import '../renderer.dart';

class IntersectionInfo {
  PointD point;
  double distance;

  IntersectionInfo({this.point, this.distance});
}

abstract class Filler {
  OpSet fill(List<PointD> points, Options o);

  List<Line> buildFillLines(List<PointD> points, Options o) {
    PointD rotationCenter = PointD(0, 0);
    double angle = (o.hachureAngle + 90).roundToDouble();
    if (angle != 0) {
      points = rotatePoints(points, rotationCenter, angle);
    }
    List<Line> lines = _straightenLines(points, o);
    if (angle != 0) {
      lines = rotateLines(lines, rotationCenter, -angle);
    }
    return lines;
  }

  List<Line> _straightenLines(List<PointD> points, Options o) {
    List<PointD> vertices = points ?? [];
    List<Line> lines = [];
    if (vertices[0] != vertices[vertices.length - 1]) {
      vertices.add(vertices[0]);
    }
    if (vertices.length > 2) {
      double gap = o.hachureGap;
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

abstract class BaseLineFiller extends Filler {
  OpSet fillPolygon(List<PointD> points, Options o, bool connectEnds) {
    List<Line> lines = buildFillLines(points, o);
    if (connectEnds) {
      List<Line> connectingLines = connectLines(points, lines);
      lines += connectingLines;
    }
    List<Op> ops = renderLines(lines, o);
    return OpSet(type: OpSetType.fillSketch, ops: ops);
  }

  List<Line> connectLines(List<PointD> polygon, List<Line> lines) {
    List<Line> result = [];
    if (lines.length > 1) {
      for (int i = 1; i < lines.length; i++) {
        Line prev = lines[i - 1];
        if (prev.length < 3) {
          continue;
        }
        Line current = lines[i];
        Line segment = Line(current.source, prev.target);
        if (segment.length > 3) {
          List<Line> segSplits = splitOnIntersections(polygon, segment);
          result.addAll(segSplits);
        }
      }
    }
    return result;
  }

  List<Line> splitOnIntersections(List<PointD> polygon, Line segment) {
    double error = max(5, segment.length * 0.1);
    List<IntersectionInfo> intersections = [];
    for (int i = 0; i < polygon.length; i++) {
      PointD p1 = polygon[i];
      PointD p2 = polygon[(i + 1) % polygon.length];
      Line polygonSegment = Line(p1, p2);
      if (segment.intersects(polygonSegment)) {
        Point ip = segment.intersectionWith(polygonSegment);
        if (ip != null) {
          double d0 = Line(ip, segment.source).length;
          double d1 = Line(ip, segment.target).length;
          if (d0 > error && d1 > error) {
            intersections.add(IntersectionInfo(point: ip, distance: d0));
          }
        }
      }
    }
    if (intersections.length > 1) {
      intersections.sort((a, b) => (a.distance - b.distance).ceil());
      List<PointD> ips = intersections.map((d) => d.point);
      if (segment.source.isInPolygon(polygon)) {
        ips.removeAt(0);
      }
      if (segment.target.isInPolygon(polygon)) {
        ips.removeLast();
      }
      if (ips.length <= 1) {
        if (segment.isMidPointInPolygon(polygon)) {
          return [segment];
        } else {
          return [];
        }
      }
      List<Point> spoints = [segment.source] + ips + [segment.target];
      List<Line> slines = [];
      for (int i = 0; i < (spoints.length - 1); i += 2) {
        Line subSegment = Line(spoints[i], spoints[i + 1]);
        if (subSegment.isMidPointInPolygon(polygon)) {
          slines.add(subSegment);
        }
      }
      return slines;
    } else if (segment.isMidPointInPolygon(polygon)) {
      return [segment];
    } else {
      return [];
    }
  }

  List<Op> renderLines(List<Line> lines, Options o) {
    List<Op> ops = [];
    lines.forEach((line) {
      ops.addAll(doubleLine(line.source.x, line.source.y, line.target.x, line.target.y, o));
    });
    return ops;
  }
}

class HachureFiller extends BaseLineFiller {
  OpSet fill(List<PointD> points, Options o) {
    return fillPolygon(points, o, false);
  }
}

class ZigZagFiller extends BaseLineFiller {
  OpSet fill(List<PointD> points, Options o) {
    return fillPolygon(points, o, true);
  }
}

class HatchFiller extends BaseLineFiller {
  OpSet fill(List<PointD> points, Options o) {
    OpSet set1 = fillPolygon(points, o, false);
    Options rotated = o.copyWith(hachureAngle: o.hachureAngle + 90);
    OpSet set2 = fillPolygon(points, rotated, false);
    return OpSet(type: OpSetType.fillSketch, ops: set1.ops + set2.ops);
  }
}

class DashedFiller extends Filler {
  OpSet fill(List<PointD> points, Options o) {
    List<Line> lines = buildFillLines(points, o);
    return OpSet(type: OpSetType.fillSketch, ops: dashedLines(lines, o));
  }

  List<Op> dashedLines(List<Line> lines, Options o) {
    double offset = o.dashOffset;
    double gap = o.dashGap;
    List<Op> ops = [];
    lines.forEach((line) {
      double length = line.length;
      int count = (length / (offset + gap)).floor();
      double lineOffset = (length + gap - (count * (offset + gap))) / 2;
      PointD lineStart = line.source;
      PointD lineEnd = line.target;
      if (lineStart.x > lineEnd.x) {
        lineStart = line.target;
        lineEnd = line.source;
      }
      double alpha = atan((lineEnd.y - lineStart.y) / (lineEnd.x - lineStart.x));
      for (int i = 0; i < count; i++) {
        double segmentStartOffset = i * (offset + gap);
        double segmentEndOffset = segmentStartOffset + offset;
        var segmentStartX = lineStart.x + (segmentStartOffset * cos(alpha)) + (lineOffset * cos(alpha));
        var segmentStartY = lineStart.y + segmentStartOffset * sin(alpha) + (lineOffset * sin(alpha));
        PointD gapStart = PointD(segmentStartX, segmentStartY);
        var segmentEndX = lineStart.x + (segmentEndOffset * cos(alpha)) + (lineOffset * cos(alpha));
        var segmentEndY = lineStart.y + (segmentEndOffset * sin(alpha)) + (lineOffset * sin(alpha));
        PointD gapEnd = PointD(segmentEndX, segmentEndY);

        ops.addAll(doubleLine(gapStart.x, gapStart.y, gapEnd.x, gapEnd.y, o));
      }
    });
    return ops;
  }
}

class DotFiller extends Filler {
  OpSet fill(List<PointD> points, Options o) {
    o = o.copyWith(curveStepCount: 4, hachureAngle: 0, roughness: 1);
    List<Line> lines = buildFillLines(points, o);
    return dotsOnLines(lines, o);
  }

  OpSet dotsOnLines(List<Line> lines, Options o) {
    List<Op> ops = [];
    double gap = o.hachureGap;
    gap = max(gap, 0.1);
    double fweight = o.fillWeight;
    double ro = gap / 4;
    lines.forEach((line) {
      double length = line.length;
      double dl = length / gap;
      int count = dl.ceil() - 1;
      double off = length - (count * gap);
      double x = ((line.source.x + line.target.x) / 2) - (gap / 4);
      double minY = min(line.source.y, line.target.y);
      for (int i = 0; i < count; i++) {
        double y = minY + off + (i * gap);
        double cx = offset(x - ro, x + ro, o, 1);
        double cy = offset(y - ro, y + ro, o, 1);
        OpSet el = ellipse(cx, cy, fweight, fweight, o);
        ops.addAll(el.ops);
      }
    });
    return OpSet(type: OpSetType.fillSketch, ops: ops);
  }
}
