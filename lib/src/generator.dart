import 'config.dart';
import 'core.dart';
import 'filler.dart';
import 'renderer.dart';

class Generator {
  Drawable _d(String shape, List<OpSet> sets, DrawConfig options) {
    return Drawable(shape: shape, sets: sets ?? List<OpSet>(), options: options);
  }

  Drawable line(double x1, double y1, double x2, double y2, {DrawConfig options}) {
    final o = options ?? DrawConfig();
    return this._d('line', [buildLine(x1, y1, x2, y2, o)], o);
  }

  Drawable rectangle(double x, double y, double width, double height,
      {DrawConfig options, FillerConfig fillerOptions = const FillerConfig()}) {
    final o = options ?? DrawConfig();
    List<OpSet> paths = [];
    OpSet outline = buildRectangle(x, y, width, height, o);
    List<PointD> points = [PointD(x, y), PointD(x + width, y), PointD(x + width, y + height), PointD(x, y + height)];
    paths.add(DotFiller().fill(points, fillerOptions));
    paths.add(outline);
    return _d('rectangle', paths, o);
  }

  Drawable circle(double x, double y, double diameter, {DrawConfig options, FillerConfig fillerOptions = const FillerConfig()}) {
    Drawable ret = this.ellipse(x, y, diameter, diameter, options: options, fillerOptions: fillerOptions);
    ret.shape = 'circle';
    return ret;
  }

  Drawable ellipse(double x, double y, double width, double height,
      {DrawConfig options, FillerConfig fillerOptions = const FillerConfig()}) {
    final o = options ?? DrawConfig();
    List<OpSet> paths = [];
    EllipseParams ellipseParams = generateEllipseParams(width, height, o);
    EllipseResult ellipseResponse = ellipseWithParams(x, y, o, ellipseParams);

//      if (o.fillStyle == 'solid') {
//        OpSet shape = ellipseResponse.opset;
//        shape.type = OpSetType.fillPath;
//        paths.add(shape);
//      } else {
    paths.add(DotFiller().fill(ellipseResponse.estimatedPoints, fillerOptions));
//      }

    paths.add(ellipseResponse.opset);

    return _d('ellipse', paths, o);
  }
}

class ComputedEllipsePoints {
  List<PointD> corePoints;
  List<PointD> allPoints;

  ComputedEllipsePoints({this.corePoints, this.allPoints});
}

class EllipseParams {
  final double rx;
  final double ry;
  final double increment;

  EllipseParams({this.rx, this.ry, this.increment});
}

class EllipseResult {
  OpSet opset;
  List<PointD> estimatedPoints;

  EllipseResult({this.opset, this.estimatedPoints});
}
