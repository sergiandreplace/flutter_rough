import 'dart:math';

import 'package:rough/src/core.dart';

import 'generator.dart';

List<Op> _line(double x1, double y1, double x2, double y2, Options o, bool move, bool overlay) {
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

  double offset = o.maxRandomnessOffset;
  if ((offset * offset * 100) > lengthSq) {
    offset = length / 10;
  }

  final halfOffset = offset / 2;
  final divergePoint = 0.2 + o.randomizer.next() * 0.2;

  double midDispX = o.bowing * o.maxRandomnessOffset * (y2 - y1) / 200;
  double midDispY = o.bowing * o.maxRandomnessOffset * (x1 - x2) / 200;
  midDispX = offsetOpt(midDispX, o, roughnessGain);
  midDispY = offsetOpt(midDispY, o, roughnessGain);

  final ops = List<Op>();
  final randomHalf = () => offsetOpt(halfOffset, o, roughnessGain);
  final randomFull = () => offsetOpt(offset, o, roughnessGain);

  if (move) {
    if (overlay) {
      ops.add(Op(OpType.move, [x1 + randomHalf(), y1 + randomHalf()]));
    } else {
      ops.add(Op(OpType.move, [x1 + offsetOpt(offset, o, roughnessGain), y1 + offsetOpt(offset, o, roughnessGain)]));
    }
  }
  if (overlay) {
    ops.add(Op(OpType.bCurveTo, [
      midDispX + x1 + (x2 - x1) * divergePoint + randomHalf(),
      midDispY + y1 + (y2 - y1) * divergePoint + randomHalf(),
      midDispX + x1 + 2 * (x2 - x1) * divergePoint + randomHalf(),
      midDispY + y1 + 2 * (y2 - y1) * divergePoint + randomHalf(),
      x2 + randomHalf(),
      y2 + randomHalf()
    ]));
  } else {
    ops.add(Op(OpType.bCurveTo, [
      midDispX + x1 + (x2 - x1) * divergePoint + randomFull(),
      midDispY + y1 + (y2 - y1) * divergePoint + randomFull(),
      midDispX + x1 + 2 * (x2 - x1) * divergePoint + randomFull(),
      midDispY + y1 + 2 * (y2 - y1) * divergePoint + randomFull(),
      x2 + randomFull(),
      y2 + randomFull()
    ]));
  }
  return ops;
}

double offset(double min, double max, Options ops, double roughnessGain) {
  return ops.roughness * roughnessGain * ((ops.randomizer.next() * (max - min)) + min);
}

double offsetOpt(double x, Options ops, double roughnessGain) {
  return offset(-x, x, ops, roughnessGain);
}

OpSet buildLine(double x1, double y1, double x2, double y2, Options options) {
  return OpSet(type: OpSetType.path, ops: doubleLine(x1, y1, x2, y2, options));
}

OpSet buildRectangle(double x, double y, double width, double height, Options options) {
  List<PointD> points = [PointD(x, y), PointD(x + width, y), PointD(x + width, y + height), PointD(x, y + height)];
  return polygon(points, options);
}

List<Op> doubleLine(double x1, double y1, double x2, double y2, Options options) {
  List<Op> o1 = _line(x1, y1, x2, y2, options, true, false);
  List<Op> o2 = _line(x1, y1, x2, y2, options, true, true);
  return o1 + o2;
}

OpSet polygon(List<PointD> points, Options options) {
  return linearPath(points, true, options);
}

OpSet linearPath(List<PointD> points, bool close, Options options) {
  int len = (points ?? []).length;
  if (len > 2) {
    List<Op> ops = [];
    for (int i = 0; i < len - 1; i++) {
      ops += doubleLine(points[i].x, points[i].y, points[i + 1].x, points[i + 1].y, options);
    }
    if (close) {
      ops += doubleLine(points[len - 1].x, points[len - 1].y, points[0].x, points[0].y, options);
    }
    return OpSet(type: OpSetType.path, ops: ops);
  } else if (len == 2) {
    return buildLine(points[0].x, points[0].x, points[1].x, points[1].x, options);
  } else {
    return OpSet(type: OpSetType.path, ops: []);
  }
}
