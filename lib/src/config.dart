import 'dart:math';

class DrawConfig {
  final double maxRandomnessOffset; //renderer
  final double roughness; //renderer
  final double bowing; //renderer
  final double curveFitting; //renderer
  final double curveTightness; //renderer
  final double curveStepCount; //renderer
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
          randomizer: Randomizer(
            seed: seed ?? defaultValues.seed,
          ));

  double offset(double min, double max, [double roughnessGain = 1]) {
    return roughness * roughnessGain * ((randomizer.next() * (max - min)) + min);
  }

  double offsetSymmetric(double x, [double roughnessGain = 1]) {
    return offset(-x, x, roughnessGain);
  }

  copyWith({
    double maxRandomnessOffset,
    double roughness,
    double bowing,
    double curveFitting,
    double curveTightness,
    double curveStepCount,
    double fillWeight,
    double hachureAngle,
    double hachureGap,
    double simplification,
    double dashOffset,
    double dashGap,
    double zigzagOffset,
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
}
