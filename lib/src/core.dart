import 'dart:math';

import 'package:flutter/material.dart';

import 'Randomizer.dart';
import 'generator.dart';
import 'geometry.dart';

class Config {
  final Options options;

  Config(this.options);
}

class Options {
  double maxRandomnessOffset;
  double roughness;
  double bowing;
  Color stroke;
  double strokeWidth;
  double curveFitting;
  double curveTightness;
  double curveStepCount;
  Color fill;
  String fillStyle;
  double fillWeight;
  double hachureAngle;
  double hachureGap;
  double simplification;
  double dashOffset;
  double dashGap;
  double zigzagOffset;
  int seed;
  bool combineNestedSvgPaths;
  Random _randomizer;

  Options({
    this.maxRandomnessOffset = 2,
    this.roughness = 1,
    this.bowing = 1,
    this.stroke = Colors.black,
    this.strokeWidth = 1,
    this.curveFitting = 0.95,
    this.curveTightness = 0,
    this.curveStepCount = 9,
    this.fill = Colors.red,
    this.fillStyle = 'hachure',
    this.fillWeight = -1,
    this.hachureAngle = -41,
    this.hachureGap = 10,
    this.simplification = 0,
    this.dashOffset = -1,
    this.dashGap = -1,
    this.zigzagOffset = -1,
    this.seed = 0,
    this.combineNestedSvgPaths = false,
  });

  Randomizer get randomizer => Randomizer(seed: this.seed);
}

class Op {
  final OpType op;
  final List<double> data;

  Op(this.op, this.data);
}

class OpSet {
  OpSetType type;
  List<Op> ops;
  Point size;
  String path;

  OpSet({this.type, this.ops, this.size, this.path});
}

class Drawable {
  String shape;
  Options options;
  List<OpSet> sets;

  Drawable({this.shape, this.options, this.sets});
}

enum OpType { move, bCurveTo, lineTo }
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
    Orient o1 = getOrientation(source, target, line.source);
    Orient o2 = getOrientation(source, target, line.target);
    Orient o3 = getOrientation(line.source, line.target, source);
    Orient o4 = getOrientation(line.source, line.target, target);

    if (o1 != o2 && o3 != o4) {
      return true;
    }
    // source, target and line.source are colinear and line.source lies on segment this.source-this.target

    if (o1 == Orient.collinear && onSegmentPoints(this.source, line.source, this.target)) {
      return true;
    }

    // this.source, this.target and line.source are collinear and line.target lies on segment this.source-this.target
    if (o2 == Orient.collinear && onSegmentPoints(this.source, line.target, this.target)) {
      return true;
    }

    // line.source, line.target and this.source are collinear and this.source lies on segment line.source-line.target
    if (o3 == Orient.collinear && onSegmentPoints(line.source, this.source, line.target)) {
      return true;
    }

    // line.source, line.target and this.target are collinear and this.target lies on segment line.source-line.target
    if (o4 == Orient.collinear && onSegmentPoints(line.source, this.target, line.target)) {
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
