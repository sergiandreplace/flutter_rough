import 'dart:math';

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
