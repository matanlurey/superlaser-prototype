import 'package:meta/meta.dart';

/// Returns an item of type [T] from a probabilistic distribution.
@internal
final class Dispenser<T> {
  /// Create a dispenser for the given [distribution].
  ///
  /// The [distribution] is a list of pairs where the first value is the weight
  /// of the item (a value between `0.0` and `1.0`) and the second value is a
  /// function that returns an instance of [T].
  ///
  /// The sum of all weights must be equal to `1.0`, _or_ [orElse] must be
  /// provided, which will be used to generate an item if the target is not
  /// found in the distribution; in other words, the remaining weight.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final dispenser = Dispenser([
  ///   (0.5, () => 'A'),
  ///   (0.3, () => 'B'),
  ///   (0.2, () => 'C'),
  /// ]);
  ///
  /// print(dispenser.dispense(0.0)); // 'A'
  /// print(dispenser.dispense(0.5)); // 'B'
  /// print(dispenser.dispense(0.8)); // 'C'
  /// ```
  ///
  /// Or, with an [orElse] function:
  ///
  /// ```dart
  /// final dispenser = Dispenser([
  ///   (0.5, () => 'A'),
  ///   (0.3, () => 'B'),
  ///   (0.1, () => 'C'),
  /// ], orElse: () => 'D');
  ///
  /// print(dispenser.dispense(0.9)); // 'D'
  /// ```
  factory Dispenser(
    Iterable<(double, T Function())> distribution, {
    T Function()? orElse,
  }) {
    final total = distribution.fold<double>(0, (sum, pair) => sum + pair.$1);
    if (total > 1.0) {
      throw ArgumentError.value(
        distribution,
        'distribution',
        'Total weight must be <= 1.0 (got $total)',
      );
    }
    if (total < 1.0 && orElse == null) {
      throw ArgumentError.value(
        distribution,
        'distribution',
        'Total weight must be >= 1.0, or provide an `orElse` function.',
      );
    }
    return Dispenser._([
      ...distribution,
      if (total < 1.0) (1.0 - total, orElse!),
    ]);
  }

  Dispenser._(this._distribution);

  final List<(double, T Function())> _distribution;

  /// Generates a random item from the provided distribution target.
  ///
  /// The [target] must be a value between 0.0 and 1.0, inclusive.
  T dispense(double target) {
    if (target < 0.0 || target > 1.0) {
      throw ArgumentError.value(
        target,
        'target',
        'Must be between 0.0 and 1.0, inclusive.',
      );
    }
    var total = 0.0;
    for (final (weight, pull) in _distribution) {
      total += weight;
      if (target < total) {
        return pull();
      }
    }
    throw StateError('Unreachable');
  }
}
