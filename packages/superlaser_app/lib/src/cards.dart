import 'package:meta/meta.dart';
import 'package:unlimited/core.dart';

/// A database of cards.
final class Database {
  /// Creates a new instance from in-memory data.
  factory Database.fromData(Expansion set, Iterable<CardOrVariant> cards) {
    final database = Database._({set.code: _Expansion(set.name, {})});
    for (final card in cards) {
      switch (card) {
        case CanonicalCard(card: final c):
          database.addCard(set.code, c.number, c.name);
        case VariantCard(number: final v, card: final c, type: _):
          database.addVariant(set.code, v, c.number);
      }
    }
    return database;
  }

  const Database._(this._expansions);

  final Map<String, _Expansion> _expansions;

  /// Adds an expansion with the given [code] and [name].
  void addExpansion(String code, String name) {
    _expansions.putIfAbsent(code, () => _Expansion(name, {}));
  }

  /// Adds a card to the given [expansion] with the given [id] and [name].
  void addCard(String expansion, int id, String name) {
    _expansions[expansion]!.cards[id] = _Card(name);
  }

  /// Adds a variant to the card with the given [id] in the given [expansion].
  void addVariant(String expansion, int id, int variant) {
    // TODO: Handle corner case of "starter" Luke/Vader which are also 1/2.
    // These override the original cards, we'll need a different approach.
    _expansions[expansion]!.cards.putIfAbsent(
          id,
          () => _Variant(variant),
        );
  }

  /// Returns the name of the expansion with the given [code].
  ///
  /// Returns `null` if the expansion does not exist.
  String? expansion(String code) => _expansions[code]?.name;

  /// Returns the name of the card with the given [id] in the given [expansion].
  ///
  /// Returns `null` if the card does not exist.
  ///
  /// If the card is a variant, the name of the card it is a variant of is
  /// returned, and the second parameter is `true`.
  (String?, bool) card(String expansion, int id) {
    final x = _expansions[expansion]?.cards[id];
    return switch (x) {
      final _Card c => (c.name, false),
      final _Variant v => (card(expansion, v.id).$1, true),
      _ => (null, false),
    };
  }
}

final class _Expansion {
  const _Expansion(this.name, this.cards);

  final String name;
  final Map<int, _Entry> cards;
}

@immutable
sealed class _Entry {
  const _Entry();
}

@immutable
final class _Card extends _Entry {
  const _Card(this.name);

  final String name;
}

@immutable
final class _Variant extends _Entry {
  const _Variant(this.id);

  final int id;
}
