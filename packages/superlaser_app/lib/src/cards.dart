import 'package:jsonut/jsonut.dart';
import 'package:meta/meta.dart';

/// A database of cards.
final class Database implements ToJson {
  /// Creates a new instance.
  factory Database() {
    return Database._(_Database({}));
  }

  const Database._(this._impl);

  /// Creates a new instance from the given [json].
  factory Database.fromJson(JsonObject json) {
    return Database._(_Database.fromJson(json));
  }

  final _Database _impl;

  /// Adds an expansion with the given [code] and [name].
  void addExpansion(String code, String name) {
    _impl.expansions.putIfAbsent(code, () => _Expansion(name, {}));
  }

  /// Adds a card to the given [expansion] with the given [id] and [name].
  void addCard(String expansion, int id, String name) {
    _impl.expansions[expansion]!.cards[id] = _Card(name);
  }

  /// Adds a variant to the card with the given [id] in the given [expansion].
  void addVariant(String expansion, int id, int variant) {
    // TODO: Handle corner case of "starter" Luke/Vader which are also 1/2.
    // These override the original cards, we'll need a different approach.
    _impl.expansions[expansion]!.cards.putIfAbsent(
      id,
      () => _Variant(variant),
    );
  }

  /// Returns the name of the expansion with the given [code].
  ///
  /// Returns `null` if the expansion does not exist.
  String? expansion(String code) => _impl.expansions[code]?.name;

  /// Returns the name of the card with the given [id] in the given [expansion].
  ///
  /// Returns `null` if the card does not exist.
  ///
  /// If the card is a variant, the name of the card it is a variant of is
  /// returned, and the second parameter is `true`.
  (String?, bool) card(String expansion, int id) {
    final x = _impl.expansions[expansion]?.cards[id];
    return switch (x) {
      final _Card c => (c.name, false),
      final _Variant v => (card(expansion, v.id).$1, true),
      _ => (null, false),
    };
  }

  @override
  JsonValue toJson() {
    return _impl.toJson();
  }
}

final class _Database implements ToJson {
  _Database(this.expansions);

  factory _Database.fromJson(JsonObject json) {
    final expansions = <String, _Expansion>{};
    for (final entry in json.entries) {
      final name = entry.key;
      final value = entry.value.object();
      final cards = <int, _Entry>{};
      for (final card in value['cards'].object().entries) {
        cards[int.parse(card.key)] = card.value is JsonString
            ? _Card(card.value.string())
            : _Variant(card.value.number().toInt());
      }
      expansions[name] = _Expansion(value['name'].string(), cards);
    }
    return _Database(expansions);
  }

  final Map<String, _Expansion> expansions;

  @override
  JsonValue toJson() {
    return JsonObject({
      for (final entry in expansions.entries)
        entry.key: JsonObject({
          'name': JsonString(entry.value.name),
          'cards': JsonObject(
            {
              for (final card in entry.value.cards.entries)
                '${card.key}': switch (card.value) {
                  final _Card c => JsonString(c.name),
                  final _Variant v => JsonNumber(v.id),
                } as JsonValue,
            },
          ),
        }),
    });
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
