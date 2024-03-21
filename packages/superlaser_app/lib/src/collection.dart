import 'dart:collection';

import 'package:jsonut/jsonut.dart';
import 'package:unlimited/core.dart';

/// Describes a card and how many copies of it are in a collection.
typedef CardWithCount = ({
  CardReference card,
  int copies,
});

/// Stores a collection of cards.
///
/// In practice, what a _card_ means is a reduced version of what is useful
/// for gameplay or for the UI - i.e. the minimum amount of data that needs to
/// be stored externally as "collected".
abstract final class Collection implements ToJson {
  /// Creates a new, empty collection.
  factory Collection() = _Collection;

  /// Creates a collection from an existing collection.
  factory Collection.from(Collection other) {
    final collection = Collection();
    for (final card in other.cards) {
      collection.set(card.card, card.copies);
    }
    return collection;
  }

  /// Creates a collection from an existing JSON array.
  ///
  /// Each element is a [JsonObject] with the following structure:
  /// ```jsonc
  /// {
  ///   "set": "sor",
  ///   "number": 1,
  ///   "foil": false,
  ///   "count": 4,
  /// }
  /// ```
  factory Collection.fromJson(JsonArray json) {
    final collection = Collection();
    for (final card in json.cast<JsonObject>()) {
      final (
        set,
        number,
        foil,
        count,
      ) = (
        card['set'].string(),
        card['number'].number().toInt(),
        card['foil'].booleanOrFalse(),
        card['count'].number().toInt(),
      );

      collection.set(
        CardReference(
          expansion: set,
          number: number,
          foil: foil,
        ),
        count,
      );
    }
    return collection;
  }

  /// Clears all cards from the collection.
  void clear();

  /// Adds a card to the collection.
  ///
  /// Returns the new count of the card in the collection.
  int add(CardReference card);

  /// Sets the amount of copies of the given card in the collection.
  void set(CardReference card, int copies);

  /// Removes a card from the collection.
  ///
  /// Returns the new count of the card in the collection.
  int remove(CardReference card);

  /// Returns the amount of copies of the given card in the collection.
  int copies(CardReference card);

  /// Returns the total number of cards in the collection.
  int get length;

  /// Returns the cards in the collection, grouped by copies.
  ///
  /// The list is always sorted by:
  /// 1. The card's set, in alphabetical ascending order.
  /// 2. The card's number, in ascending order.
  /// 3. Foil cards come after non-foil cards.
  ///
  /// See [CardReference.compareTo] for more details.
  Iterable<CardWithCount> get cards;
}

/// A naive implementation that uses a [SplayTreeMap].
final class _Collection implements Collection {
  final _cards = SplayTreeMap<CardReference, int>();

  @override
  void clear() {
    _cards.clear();
  }

  @override
  int add(CardReference card) {
    var value = _cards[card] ?? 0;
    _cards[card] = ++value;
    return value;
  }

  @override
  void set(CardReference card, int copies) {
    RangeError.checkNotNegative(copies, 'copies');
    if (copies == 0) {
      _cards.remove(card);
    } else {
      _cards[card] = copies;
    }
  }

  @override
  int remove(CardReference card) {
    final count = _cards[card];
    if (count == null) {
      return 0;
    }
    if (count == 1) {
      _cards.remove(card);
      return 0;
    }
    return _cards[card] = count - 1;
  }

  @override
  int copies(CardReference card) {
    return _cards[card] ?? 0;
  }

  @override
  int get length => _cards.values.fold(0, (a, b) => a + b);

  @override
  Iterable<CardWithCount> get cards {
    return _cards.entries.map((e) => (card: e.key, copies: e.value));
  }

  @override
  JsonValue toJson() {
    final cards = _cards.entries.map(
      (e) => JsonObject({
        'set': JsonString(e.key.expansion),
        'number': JsonNumber(e.key.number),
        'foil': JsonBoolean(e.key.foil),
        'count': JsonNumber(e.value),
      }),
    );
    return JsonArray(cards.toList());
  }
}
