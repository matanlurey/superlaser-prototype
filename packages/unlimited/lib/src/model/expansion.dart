import 'package:meta/meta.dart';

/// Expansion, or set, of cards.
///
/// Expansions are used to group cards together by the set in which they were
/// printed. Expansions are also used to determine the legality of a card in a
/// given format.
///
/// Known formats are static members of this class. See also: [values].
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
final class Expansion {
  /// Ceates an expansion with the given [name] and [code].
  factory Expansion({
    required String name,
    required String code,
    required int count,
    DateTime? release,
  }) {
    return Expansion._(
      name: name,
      code: code,
      count: count,
      release: release,
    );
  }

  @literal
  const Expansion._({
    required this.name,
    required this.code,
    required this.count,
    this.release,
  });

  /// See <https://starwarsunlimited.com/products/set-1-spark-of-rebellion>.
  static final sparkOfRebellion = Expansion._(
    name: 'Spark of Rebellion',
    code: 'sor',
    count: 252,
    release: DateTime(2024, 3, 8),
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

  /// The date on which the expansion was released globally.
  ///
  /// If the expansion does not have a release date, this field is `null`.
  final DateTime? release;

  @override
  bool operator ==(Object other) {
    return other is Expansion && other.code == code;
  }

  @override
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
