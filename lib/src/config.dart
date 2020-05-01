import 'dart:math';

class DrawConfig {
  final double maxRandomnessOffset; //renderer
  final double roughness; //renderer
  final double bowing; //renderer
  final double curveFitting; //renderer
  final double curveTightness; //renderer
  final double curveStepCount; //renderer
  final int seed;

  const DrawConfig({
    this.maxRandomnessOffset = 2,
    this.roughness = 1,
    this.bowing = 1,
    this.curveFitting = 0.95,
    this.curveTightness = 0,
    this.curveStepCount = 9,
    this.seed = 0,
  });

  Randomizer get randomizer => Randomizer(seed: this.seed);

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
  }) =>
      DrawConfig(
        maxRandomnessOffset: maxRandomnessOffset ?? this.maxRandomnessOffset,
        roughness: roughness ?? this.roughness,
        bowing: bowing ?? this.bowing,
        curveFitting: curveFitting ?? this.curveFitting,
        curveTightness: curveTightness ?? this.curveTightness,
        curveStepCount: curveStepCount ?? this.curveStepCount,
        seed: seed ?? this.seed,
      );
}

class Randomizer {
  static Randomizer _randomizer;
  int _seed;
  Random _random;

  factory Randomizer({int seed = 0}) {
    if (_randomizer == null || _randomizer._seed != seed) {
      _randomizer = Randomizer._();
      _randomizer._seed = seed;
      _randomizer._random = Random(seed);
    }
    return _randomizer;
  }

  double next() => _random.nextDouble();

  get seed => _seed;

  Randomizer._();
}
