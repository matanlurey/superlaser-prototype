import 'package:meta/meta.dart';

/// Expansion, or set, of cards.
///
/// Expansions are used to group cards together by the set in which they were
/// printed. Expansions are also used to determine the legality of a card in a
/// given format.
///
/// Known formats are static members of this class.
///
/// ## Comparison
///
/// Expansions are compared by their release date, in ascending order, or the
/// estimated release date if the expansion has not been released yet. See
/// [values] for the list of known expansions in sorted order.
///
/// ## Equality
///
/// Two expansions are considered equal if they have the same [code].
///
/// ## Example
///
/// ```dart
/// final sor = Expansion(name: 'Spark of Rebellion', code: 'sor');
/// ```
@immutable
sealed class Expansion implements Comparable<Expansion> {
  const Expansion({
    required this.name,
    required this.code,
    required this.count,
  });

  /// See <https://starwarsunlimited.com/products/set-1-spark-of-rebellion>.
  static final sparkOfRebellion = ReleasedExpansion(
    name: 'Spark of Rebellion',
    code: 'sor',
    count: 252,
    released: DateTime(2024, 3, 8),
  );

  /// All known expansions, sorted by release date in ascending order.
  static final values = List<Expansion>.unmodifiable([
    sparkOfRebellion,
  ]);

  /// The name of the expansion.
  ///
  /// Must be non-empty.
  final String name;

  /// The code for the expansion.
  ///
  /// Must be non-empty, unique, and lowercase.
  final String code;

  /// The number of cards in the expansion upon full release.
  ///
  /// Must be at least 1.
  final int count;

  @override
  @nonVirtual
  int compareTo(Expansion other) {
    // If both expansions have been released, compare by release date.
    // If one expansion has not been released, the released expansion is first.
    // If both expansions have not been released, compare by estimated release.
    return switch (this) {
      final ReleasedExpansion a => switch (other) {
          final ReleasedExpansion b => a.released.compareTo(b.released),
          final UnreleasedExpansion _ => -1,
        },
      final UnreleasedExpansion a => switch (other) {
          final ReleasedExpansion _ => 1,
          final UnreleasedExpansion b =>
            a.releaseEstimate.compareTo(b.releaseEstimate),
        },
    };
  }

  @override
  @nonVirtual
  bool operator ==(Object other) {
    return other is Expansion && other.code == code;
  }

  @override
  @nonVirtual
  int get hashCode => code.hashCode;

  /// Returns a formatted string representation of the [card] number.
  ///
  /// The format is `$code $number/$count` with leading zeroes for the number.
  String formatCard(int card) {
    final count = '${this.count}';
    final number = card.toString().padLeft(count.length, '0');
    return '${code.toUpperCase()} $number/$count';
  }

  @override
  String toString() => 'Expansion <$code>';
}

/// A released expansion.
final class ReleasedExpansion extends Expansion {
  /// Creates a released expansion with a [released] date in the past.
  const ReleasedExpansion({
    required super.name,
    required super.code,
    required super.count,
    required this.released,
  });

  /// The release date of the expansion, in UTC.
  ///
  /// Must be in the past.
  final DateTime released;
}

/// An expansion that has _not_ been released yet.
final class UnreleasedExpansion extends Expansion {
  /// Creates a released expansion with a [releaseEstimate] date.
  const UnreleasedExpansion({
    required super.name,
    required super.code,
    required super.count,
    required this.releaseEstimate,
  });

  /// The estimated release date of the expansion, in UTC.
  final DateTime releaseEstimate;
}
