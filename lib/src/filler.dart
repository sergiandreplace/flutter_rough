import 'dart:math';

import 'config.dart';
import 'core.dart';
import 'entities.dart';
import 'geometry.dart';
import 'renderer.dart';

class IntersectionInfo {
  PointD point;
  double distance;

  IntersectionInfo({this.point, this.distance});
}

enum FillStyle { fill, sketch }

class FillerConfig {
  final DrawConfig _drawConfig;
  final double fillWeight;
  final double hachureAngle;
  final double hachureGap;
  final double dashOffset;
  final double dashGap;
  final double zigzagOffset;

  const FillerConfig._({
    DrawConfig drawConfig,
    this.fillWeight,
    this.hachureAngle,
    this.hachureGap,
    this.dashOffset,
    this.dashGap,
    this.zigzagOffset,
  }) : _drawConfig = drawConfig;

  /// * [fillWeight] When using dots styles to fill the shape, this value represents the diameter of the dot.
  /// * [hachureAngle] Numerical value (in degrees) that defines the angle of the hachure lines. Default value is -41 degrees.
  /// * [hachureGap] Numerical value that defines the average gap, in pixels, between two hachure lines. Default value is 15.
  /// * [dashOffset] When filling a shape using the [DashedFiller], this property indicates the nominal length of dash (in pixels). If not set, it defaults to the hachureGap value.
  /// * [dashGap] When filling a shape using the [DashedFiller], this property indicates the nominal gap between dashes (in pixels). If not set, it defaults to the hachureGap value.
  /// * [zigzagOffset] When filling a shape using the [ZigZagLineFiller], this property indicates the nominal width of the zig-zag triangle in each line. If not set, it defaults to the hachureGap value.
  static FillerConfig build({
    DrawConfig drawConfig,
    double fillWeight = 1,
    double hachureAngle = 320,
    double hachureGap = 15,
    double dashOffset = 15,
    double dashGap = 2,
    double zigzagOffset = 5,
  }) =>
      FillerConfig._(
        drawConfig: drawConfig,
        fillWeight: fillWeight,
        hachureAngle: hachureAngle,
        hachureGap: hachureGap,
        dashOffset: dashOffset,
        dashGap: dashGap,
        zigzagOffset: zigzagOffset,
      );

  static FillerConfig defaultConfig = FillerConfig.build(drawConfig: DrawConfig.defaultValues);

  DrawConfig get drawConfig => _drawConfig;

  FillerConfig copyWith({
    DrawConfig drawConfig,
    double fillWeight,
    double hachureAngle,
    double hachureGap,
    double dashOffset,
    double dashGap,
    double zigzagOffset,
  }) =>
      FillerConfig._(
        drawConfig: drawConfig ?? _drawConfig,
        fillWeight: fillWeight ?? this.fillWeight,
        hachureAngle: hachureAngle ?? this.hachureAngle,
        hachureGap: hachureGap ?? this.hachureGap,
        dashOffset: dashOffset ?? this.dashOffset,
        dashGap: dashGap ?? this.dashGap,
        zigzagOffset: zigzagOffset ?? this.zigzagOffset,
      );
}

abstract class Filler {
  final FillerConfig config;

  Filler(this.config) : assert(config != null, 'FillerConfig could not be null');

  OpSet fill(List<PointD> points);

  List<Line> buildFillLines(List<PointD> points, FillerConfig config) {
    PointD rotationCenter = PointD(0, 0);
    double angle = (config.hachureAngle + 90).roundToDouble();
    if (angle != 0) {
      points = rotatePoints(points, rotationCenter, angle);
    }
    List<Line> lines = _straightenLines(points);
    if (angle != 0) {
      lines = rotateLines(lines, rotationCenter, -angle);
    }
    return lines;
  }

  List<Line> _straightenLines(List<PointD> points) {
    List<PointD> vertices = points ?? [];
    List<Line> lines = [];
    if (vertices[0] != vertices[vertices.length - 1]) {
      vertices.add(vertices[0]);
    }
    if (vertices.length > 2) {
      double gap = config.hachureGap;
      gap = max(gap, 0.1);

      List<Edge> edges = createdSortedEdges(vertices);
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
          for (Edge edge in removed) {
            activeEdges.add(ActiveEdge(y, edge));
          }
        }
        activeEdges = activeEdges.where((ae) => ae.edge.yMax > y).toList();

        // ignore: cascade_invocations
        activeEdges.sort((ae1, ae2) => ae1.edge.x.compareTo(ae2.edge.x));

        // fill between the edges
        if (activeEdges.length > 1) {
          for (int i = 0; i < activeEdges.length; i = i + 2) {
            int next = i + 1;
            if (next >= activeEdges.length) {
              break;
            }
            Edge ce = activeEdges[i].edge;
            Edge ne = activeEdges[next].edge;
            lines.add(Line(PointD(ce.x.roundToDouble(), y), PointD(ne.x.roundToDouble(), y)));
          }
        }

        y += gap;
        activeEdges = activeEdges.map((ae) {
          return ActiveEdge(ae.s, ae.edge.copyWith(x: ae.edge.x + (gap * ae.edge.slope)));
        }).toList();
      }
    }
    return lines;
  }

  List<Edge> createdSortedEdges(List<PointD> vertices) {
    // Create sorted edges table
    List<Edge> edges = [];
    for (int i = 0; i < vertices.length - 1; i++) {
      PointD p1 = vertices[i];
      PointD p2 = vertices[i + 1];
      if (p1.y != p2.y) {
        double yMin = min(p1.y, p2.y);
        edges.add(Edge(
          yMin: yMin,
          yMax: max(p1.y, p2.y),
          x: yMin == p1.y ? p1.x : p2.x,
          slope: (p2.x - p1.x) / (p2.y - p1.y),
        ));
      }
    }
    edges.sort(edgeSorter);
    return edges;
  }

  int edgeSorter(Edge e1, Edge e2) {
    if (e1.yMin < e2.yMin) {
      return -1;
    }
    if (e1.yMin > e2.yMin) {
      return 1;
    }
    if (e1.x < e2.x) {
      return -1;
    }
    if (e1.x > e2.x) {
      return 1;
    }
    return e1.yMax.compareTo(e2.yMax);
  }

  OpSet fillPolygon(List<PointD> points, FillerConfig config, bool connectEnds) {
    List<Line> lines = buildFillLines(points, config);
    if (connectEnds) {
      List<Line> connectingLines = connectLines(points, lines);
      lines += connectingLines;
    }
    List<Op> ops = renderLines(lines, config);
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
        PointD ip = segment.intersectionWith(polygonSegment);
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
      List<PointD> intersectionPoints = intersections.map((d) => d.point).toList();
      if (segment.source.isInPolygon(polygon)) {
        intersectionPoints.removeAt(0);
      }
      if (segment.target.isInPolygon(polygon)) {
        intersectionPoints.removeLast();
      }
      if (intersectionPoints.length <= 1) {
        if (segment.isMidPointInPolygon(polygon)) {
          return [segment];
        } else {
          return [];
        }
      }
      List<PointD> splitPoints = [segment.source] + intersectionPoints + [segment.target];
      List<Line> splitLines = [];
      for (int i = 0; i < (splitPoints.length - 1); i += 2) {
        Line subSegment = Line(splitPoints[i], splitPoints[i + 1]);
        if (subSegment.isMidPointInPolygon(polygon)) {
          splitLines.add(subSegment);
        }
      }
      return splitLines;
    } else if (segment.isMidPointInPolygon(polygon)) {
      return [segment];
    } else {
      return [];
    }
  }

  List<Op> renderLines(List<Line> lines, FillerConfig config) {
    List<Op> ops = [];
    for (Line line in lines) {
      ops.addAll(
        OpSetBuilder.buildLine(
          line.source.x,
          line.source.y,
          line.target.x,
          line.target.y,
          config.drawConfig,
        ).ops,
      );
    }
    return ops;
  }
}

class NoFiller extends Filler {
  NoFiller([FillerConfig config]) : super(config);

  @override
  OpSet fill(List<PointD> points) {
    return OpSet(type: OpSetType.fillSketch, ops: []);
  }
}

class HachureFiller extends Filler {
  HachureFiller([FillerConfig config]) : super(config);

  @override
  OpSet fill(List<PointD> points) {
    return fillPolygon(points, config, false);
  }
}

class ZigZagFiller extends Filler {
  ZigZagFiller([FillerConfig config]) : super(config);

  @override
  OpSet fill(List<PointD> points) {
    return fillPolygon(points, config, true);
  }
}

class HatchFiller extends Filler {
  HatchFiller([FillerConfig config]) : super(config);

  @override
  OpSet fill(List<PointD> points) {
    OpSet set1 = fillPolygon(points, config, false);
    FillerConfig rotated = config.copyWith(hachureAngle: config.hachureAngle + 90);
    OpSet set2 = fillPolygon(points, rotated, false);
    return OpSet(type: OpSetType.fillSketch, ops: set1.ops + set2.ops);
  }
}

class DashedFiller extends Filler {
  DashedFiller([FillerConfig config]) : super(config);

  @override
  OpSet fill(List<PointD> points) {
    List<Line> lines = buildFillLines(points, config);
    return OpSet(type: OpSetType.fillSketch, ops: dashedLines(lines, config));
  }

  List<Op> dashedLines(List<Line> lines, FillerConfig config) {
    double offset = config.dashOffset;
    double gap = config.dashGap;
    List<Op> ops = [];
    for (Line line in lines) {
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

        ops.addAll(OpsGenerator.doubleLine(gapStart.x, gapStart.y, gapEnd.x, gapEnd.y, config.drawConfig));
      }
    }
    return ops;
  }
}

class DotFiller extends Filler {
  DotFiller([FillerConfig config]) : super(config);

  @override
  OpSet fill(List<PointD> points) {
    FillerConfig dotConfig = config.copyWith(
      drawConfig: config.drawConfig.copyWith(curveStepCount: 4, roughness: 1),
      hachureAngle: 1,
    );
    List<Line> lines = buildFillLines(points, dotConfig);
    return dotsOnLines(lines, dotConfig);
  }

  OpSet dotsOnLines(List<Line> lines, FillerConfig config) {
    List<Op> ops = [];
    final double gap = max(config.hachureGap, 0.1);
    final double fWeight = max(config.fillWeight, 0.1);
    final double ro = gap / 4;
    for (Line line in lines) {
      final double length = line.length;
      final double dl = length / gap;
      final int count = dl.ceil() - 1;
      final double off = length - (count * gap);
      final double x = ((line.source.x + line.target.x) / 2) - (gap / 4);
      final double minY = min(line.source.y, line.target.y);
      for (int i = 0; i < count; i++) {
        double y = minY + off + (i * gap);
        double cx = config.drawConfig.offset(x - ro, x + ro);
        double cy = config.drawConfig.offset(y - ro, y + ro);
        OpSet el = OpSetBuilder.ellipse(cx, cy, fWeight, fWeight, config.drawConfig);
        ops.addAll(el.ops);
      }
    }
    return OpSet(type: OpSetType.fillSketch, ops: ops);
  }
}

class SolidFiller extends Filler {
  SolidFiller([FillerConfig config]) : super(config);

  @override
  OpSet fill(List<PointD> points) {
    List<Op> ops = [];
    if (points.isNotEmpty) {
      double offset = config.drawConfig.maxRandomnessOffset;
      int len = points.length;
      if (len > 2) {
        ops.add(Op.move(PointD(
          points[0].x + config.drawConfig.offsetSymmetric(offset),
          points[0].y + config.drawConfig.offsetSymmetric(offset),
        )));
      }
    }
    return OpSet(type: OpSetType.fillPath, ops: ops);
  }
}
