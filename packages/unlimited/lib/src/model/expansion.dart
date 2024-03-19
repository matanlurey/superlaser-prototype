import 'package:meta/meta.dart';

/// Expansion, or set, of a card.
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
  /// See <https://starwarsunlimited.com/products/set-1-spark-of-rebellion>.
  static final sparkOfRebellion = Expansion._(
    name: 'Spark of Rebellion',
    code: 'sor',
    release: DateTime(2024, 3, 8),
  );

  /// All known expansions, sorted by release date in ascending order.
  static final values = List<Expansion>.unmodifiable([
    sparkOfRebellion,
  ]);

  /// Returns or creates an expansion with the given [name] and [code].
  factory Expansion({
    required String name,
    required String code,
    DateTime? release,
  }) {
    return values.firstWhere((v) => code == v.code, orElse: () {
      return Expansion._(name: name, code: code, release: release);
    });
  }

  @literal
  const Expansion._({
    required this.name,
    required this.code,
    this.release,
  });

  /// The name of the expansion.
  ///
  /// Must be non-empty.
  final String name;

  /// The code for the expansion.
  ///
  /// Must be non-empty, unique, and lowercase.
  final String code;

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

  @override
  String toString() => 'Expansion <$code>';
}
