import 'config.dart';
import 'core.dart';
import 'entities.dart';
import 'filler.dart';
import 'geometry.dart';
import 'renderer.dart';

/// [Generator] is class that lets you create a [Drawable] object for a shape.
class Generator {
  final DrawConfig drawConfig;
  final Filler filler;

  Generator(this.drawConfig, this.filler)
      : assert(drawConfig != null),
        assert(filler != null);

  Drawable _buildDrawable(OpSet drawSets, [List<PointD> fillPoints]) {
    final List<OpSet> sets = [];
    if (fillPoints != null) {
      sets.add(filler.fill(fillPoints));
    }
    sets.add(drawSets);
    return Drawable(sets: sets, options: drawConfig);
  }

  /// Draws a line from ([x1], [y1]) to ([x2], [y2]).
  Drawable line(double x1, double y1, double x2, double y2) {
    return _buildDrawable(OpSetBuilder.buildLine(x1, y1, x2, y2, drawConfig));
  }

  ///Draws a rectangle with the top-left corner at ([x], [y]) with the specified [width] and [height].
  Drawable rectangle(double x, double y, double width, double height) {
    final List<PointD> points = [PointD(x, y), PointD(x + width, y), PointD(x + width, y + height), PointD(x, y + height)];
    final OpSet outline = OpSetBuilder.buildPolygon(points, drawConfig);
    return _buildDrawable(outline, points);
  }

  ///Draws a rectangle with the center at ([x], [y]) with the specified [width] and [height].
  Drawable ellipse(double x, double y, double width, double height) {
    final EllipseParams ellipseParams = generateEllipseParams(width, height, drawConfig);
    final EllipseResult ellipseResponse = ellipseWithParams(x, y, drawConfig, ellipseParams);
    return _buildDrawable(ellipseResponse.opSet, ellipseResponse.estimatedPoints);
  }

  ///Draws a rectangle with the center at ([x], [y]) with the specified [diameter].
  Drawable circle(double x, double y, double diameter) {
    final Drawable ret = ellipse(x, y, diameter, diameter);
    return ret;
  }

  /// Draws a set of lines connecting the specified points.
  //
  // * [points] is an array of [PointD]
  Drawable linearPath(List<PointD> points) {
    return _buildDrawable(OpSetBuilder.linearPath(points, true, drawConfig));
  }

  /// Draws a polygon with the specified vertices.
  ///
  /// * [points] is an array of [PointD]
  Drawable polygon(List<PointD> points) {
    final OpSet path = OpSetBuilder.linearPath(points, true, drawConfig);
    return _buildDrawable(path, points);
  }

  ///Draws an arc. An arc is described as a section of an ellipse.
  ///
  /// * [x], [y] represents the center of that ellipse
  /// * [width], [height] are the dimensions of that ellipse.
  /// * [start], [stop] are the start and stop angles for the arc.
  /// * [closed] is a boolean argument. If true, lines are drawn to connect the two end points of the arc to the center.
  Drawable arc(double x, double y, double width, double height, double start, double stop, [bool closed = false]) {
    final OpSet outline = OpSetBuilder.arc(PointD(x, y), width, height, start, stop, closed, true, drawConfig);
    final List<PointD> fillPoints = OpSetBuilder.arcPolygon(PointD(x, y), width, height, start, stop, drawConfig);
    return _buildDrawable(outline, fillPoints);
  }

  ///Draws a curve passing through the points passed in.
  ///
  /// * [points] is an array of [PointD]
  Drawable curvePath(List<PointD> points) {
    return _buildDrawable(OpSetBuilder.curve(points, drawConfig));
  }
}
