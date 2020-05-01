import 'package:rough/src/filler/scan_line_hachure.dart';

import '../core.dart';
import '../generator.dart';
import '../renderer.dart';

class IntersectionInfo {
  PointD point;
  double distance;

  IntersectionInfo({this.point, this.distance});
}

class HachureFiller {
  OpSet fillPolygon(List<PointD> points, Options o) {
    return _fillPolygon(points, o);
  }

  OpSet _fillPolygon(List<PointD> points, Options o, {bool connectEnds = false}) {
    List<Line> lines = polygonHachureLines(points, o);
//    if (connectEnds) {
//      List<Line> connectingLines = connectLines(points, lines);
//      lines += connectingLines;
//    }
    List<Op> ops = renderLines(lines, o);
    return OpSet(type: OpSetType.fillSketch, ops: ops);
  }

//  List<Line> connectLines(List<PointD> polygon, List<Line> lines) {
//    List<Line> result = [];
//    if (lines.length > 1) {
//      for (int i = 1; i < lines.length; i++) {
//        Line prev = lines[i - 1];
//        if (prev.length < 3) {
//          continue;
//        }
//        Line current = lines[i];
//        Line segment = Line(current.source, prev.target);
//        if (segment.length > 3) {
//          List<Line> segSplits = splitOnIntersections(polygon, segment);
//          result.addAll(segSplits);
//        }
//      }
//    }
//    return result;
//  }

//  List<Line> splitOnIntersections(List<PointD> polygon, Line segment) {
//    double error = max(5, segment.length * 0.1);
//    List<IntersectionInfo> intersections = [];
//    for (int i = 0; i < polygon.length; i++) {
//      PointD p1 = polygon[i];
//      PointD p2 = polygon[(i + 1) % polygon.length];
//      Line polygonSegment = Line(p1, p2);
//      if (segment.intersects(polygonSegment)) {
//        Point ip = segment.intersectionWith(polygonSegment);
//        if (ip != null) {
//          double d0 = Line(ip, segment.source).length;
//          double d1 = Line(ip, segment.target).length;
//          if (d0 > error && d1 > error) {
//            intersections.add(IntersectionInfo(point: ip, distance: d0));
//          }
//        }
//      }
//    }
//    if (intersections.length > 1) {
//      intersections.sort((a, b) => (a.distance - b.distance).ceil());
//      List<PointD> ips = intersections.map((d) => d.point);
//      if (segment.source.isInPolygon(polygon)) {
//        ips.removeAt(0);
//      }
//      if (segment.target.isInPolygon(polygon)) {
//        ips.removeLast();
//      }
//      if (ips.length <= 1) {
//        if (segment.isMidPointInPolygon(polygon)) {
//          return [segment];
//        } else {
//          return [];
//        }
//      }
//      List<Point> spoints = [segment.source] + ips + [segment.target];
//      List<Line> slines = [];
//      for (int i = 0; i < (spoints.length - 1); i += 2) {
//        Line subSegment = Line(spoints[i], spoints[i + 1]);
//        if (subSegment.isMidPointInPolygon(polygon)) {
//          slines.add(subSegment);
//        }
//      }
//      return slines;
//    } else if (segment.isMidPointInPolygon(polygon)) {
//      return [segment];
//    } else {
//      return [];
//    }
//  }

  List<Op> renderLines(List<Line> lines, Options o) {
    List<Op> ops = [];
    lines.forEach((line) {
      ops.addAll(doubleLine(line.source.x, line.source.y, line.target.x, line.target.y, o));
    });
    return ops;
  }
}
