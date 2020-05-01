import 'dart:math';

import 'package:rough/src/filler/scan_line_hachure.dart';

import '../core.dart';
import '../generator.dart';
import '../renderer.dart';

class IntersectionInfo {
  PointD point;
  double distance;

  IntersectionInfo({this.point, this.distance});
}

abstract class _LineFiller {
  OpSet fillPolygon(List<PointD> points, Options o, bool connectEnds) {
    List<Line> lines = polygonHachureLines(points, o);
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

class HachureFiller extends _LineFiller {
  OpSet fill(List<PointD> points, Options o) {
    return fillPolygon(points, o, false);
  }
}

class ZigZagFiller extends _LineFiller {
  OpSet fill(List<PointD> points, Options o) {
    return fillPolygon(points, o, true);
  }
}

class HatchFiller extends _LineFiller {
  OpSet fill(List<PointD> points, Options o) {
    OpSet set1 = fillPolygon(points, o, false);
    Options rotated = o.copyWith(hachureAngle: o.hachureAngle + 90);
    OpSet set2 = fillPolygon(points, rotated, false);
    return OpSet(type: OpSetType.fillSketch, ops: set1.ops + set2.ops);
  }
}

class DashedFiller {
  OpSet fill(List<PointD> points, Options o) {
    List<Line> lines = polygonHachureLines(points, o);
    return OpSet(type: OpSetType.fillSketch, ops: dashedLines(lines, o));
  }

  List<Op> dashedLines(List<Line> lines, Options o) {
    double offset = o.dashOffset < 0 ? (o.hachureGap < 0 ? (o.strokeWidth * 4) : o.hachureGap) : o.dashOffset;
    double gap = o.dashGap < 0 ? (o.hachureGap < 0 ? (o.strokeWidth * 4) : o.hachureGap) : o.dashGap;
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
