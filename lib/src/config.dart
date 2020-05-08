import 'dart:math';

// Describe how a particular shape is drawn.
class DrawConfig {
  final double maxRandomnessOffset;
  final double roughness;
  final double bowing;
  final double curveFitting;
  final double curveTightness;
  final double curveStepCount;
  final int seed;
  final Randomizer randomizer;

  static DrawConfig defaultValues = DrawConfig.build(
    maxRandomnessOffset: 2,
    roughness: 1,
    bowing: 1,
    curveFitting: 0.95,
    curveTightness: 0,
    curveStepCount: 9,
    seed: 1,
  );

  const DrawConfig._({
    this.maxRandomnessOffset,
    this.roughness,
    this.bowing,
    this.curveFitting,
    this.curveTightness,
    this.curveStepCount,
    this.seed,
    this.randomizer,
  });

  /// Generates a [DrawConfig]
  /// * [roughness] Numerical value indicating how rough the drawing is. A rectangle with the roughness of 0 would be a perfect rectangle. Default value is 1. There is no upper limit to this value, but a value over 10 is mostly useless.
  /// * [bowing] Numerical value indicating how curvy the lines are when drawing a sketch. A value of 0 will cause straight lines. Default value is 1.
  /// * [seed] The seed for creating random values used in shape generation. This is useful for creating the exact shape when re-generating with the same parameters. Default value is 1.
  /// * [curveStepCount] When drawing ellipses, circles, and arcs, Rough approximates [curveStepCount] number of points to estimate the shape. Default value is 9.
  /// * [curveTightness]
  /// * [curveFitting] When drawing ellipses, circles, and arcs, it means how close should the rendered dimensions be when compared to the specified one. Default value is 0.95.
  static DrawConfig build({
    double maxRandomnessOffset,
    double roughness,
    double bowing,
    double curveFitting,
    double curveTightness,
    double curveStepCount,
    int seed,
  }) =>
      DrawConfig._(
          maxRandomnessOffset: maxRandomnessOffset ?? defaultValues.maxRandomnessOffset,
          roughness: roughness ?? defaultValues.roughness,
          bowing: bowing ?? defaultValues.bowing,
          curveFitting: curveFitting ?? defaultValues.curveFitting,
          curveTightness: curveTightness ?? defaultValues.curveTightness,
          curveStepCount: curveStepCount ?? defaultValues.curveStepCount,
          seed: seed ?? defaultValues.seed,
          randomizer: Randomizer(seed: seed ?? defaultValues.seed));

  double offset(double min, double max, [double roughnessGain = 1]) {
    return roughness * roughnessGain * ((randomizer.next() * (max - min)) + min);
  }

  double offsetSymmetric(double x, [double roughnessGain = 1]) {
    return offset(-x, x, roughnessGain);
  }

  DrawConfig copyWith({
    double maxRandomnessOffset,
    double roughness,
    double bowing,
    double curveFitting,
    double curveTightness,
    double curveStepCount,
    double fillWeight,
    int seed,
    bool combineNestedSvgPaths,
    Randomizer randomizer,
  }) =>
      DrawConfig._(
          maxRandomnessOffset: maxRandomnessOffset ?? this.maxRandomnessOffset,
          roughness: roughness ?? this.roughness,
          bowing: bowing ?? this.bowing,
          curveFitting: curveFitting ?? this.curveFitting,
          curveTightness: curveTightness ?? this.curveTightness,
          curveStepCount: curveStepCount ?? this.curveStepCount,
          seed: seed ?? this.seed,
          randomizer: randomizer ?? (this.randomizer == null ? null : Randomizer(seed: this.randomizer.seed)));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawConfig &&
          runtimeType == other.runtimeType &&
          maxRandomnessOffset == other.maxRandomnessOffset &&
          roughness == other.roughness &&
          bowing == other.bowing &&
          curveFitting == other.curveFitting &&
          curveTightness == other.curveTightness &&
          curveStepCount == other.curveStepCount &&
          seed == other.seed &&
          randomizer == other.randomizer;

  @override
  int get hashCode =>
      maxRandomnessOffset.hashCode ^
      roughness.hashCode ^
      bowing.hashCode ^
      curveFitting.hashCode ^
      curveTightness.hashCode ^
      curveStepCount.hashCode ^
      seed.hashCode ^
      randomizer.hashCode;
}

class Randomizer {
  Random _random;
  int _seed;

  Randomizer({int seed = 0}) {
    _seed = seed;
    _random = Random(seed);
  }

  int get seed => _seed;

  double next() => _random.nextDouble();

  void reset() {
    _random = Random(_seed);
  }
}
