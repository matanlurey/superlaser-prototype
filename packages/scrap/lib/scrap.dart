import 'package:jsonut/jsonut.dart';
import 'package:meta/meta.dart';

extension on String {
  String capitalize() {
    return isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : this;
  }
}

void _checkNotEmpty(String value, String name) {
  if (value.isEmpty) {
    throw ArgumentError.value(value, name, 'must not be empty');
  }
}

final _lowerCaseLetters = RegExp(r'^[a-z]+$');
void _checkLowerCaseAndLettersOnly(String value, String name) {
  if (!value.contains(_lowerCaseLetters)) {
    throw ArgumentError.value(
      value,
      name,
      'must contain only lowercase letters',
    );
  }
}

void _checkAtLeast0(int value, String name) {
  if (value < 0) {
    throw ArgumentError.value(value, name, 'must be at least 0');
  }
}

void _checkAtLeast1(int value, String name) {
  if (value < 1) {
    throw ArgumentError.value(value, name, 'must be at least 1');
  }
}

void _checkInRange(int value, int min, int max, String name) {
  RangeError.checkValueInInterval(value, min, max, name);
}

void _checkUniqueAndOrderedBy<T, C extends Comparable<C>>(
  Iterable<T> elements,
  C Function(T) by, [
  String? name,
]) {
  C? last;
  for (final element in elements) {
    final current = by(element);
    if (last case final C last) {
      if (current.compareTo(last) <= 0) {
        throw ArgumentError.value(
          current,
          'elements',
          'must be unique and ordered '
              '${name == null ? '' : 'by $name '}'
              '(last: $last, current: $current)',
        );
      }
    }
    last = current;
  }
}

/// Represents a data-pack from an expansion (set).
final class Expansion {
  Expansion({
    required this.name,
    required this.code,
    required this.count,
    this.cards = const [],
  }) {
    _checkNotEmpty(name, 'name');
    _checkNotEmpty(code, 'code');
    _checkLowerCaseAndLettersOnly(code, 'code');
    _checkAtLeast1(count, 'count');
    _checkInRange(cards.length, 0, count, 'cards.length');
    _checkUniqueAndOrderedBy<Card, num>(cards, (c) => c.number, 'Card.number');
  }

  factory Expansion.fromJson(JsonObject json) {
    return Expansion(
      name: json['name'].as(),
      code: json['code'].as(),
      count: json['count'].as(),
      cards: json['cards']
          .arrayOrEmpty()
          .cast<JsonObject>()
          .mapUnmodifiable(Card.fromJson),
    );
  }

  /// The name of the expansion, such as `Spark of Rebellion`.
  ///
  /// This value is always non-empty.
  final String name;

  /// The code of the expansion, such as `sor`.
  ///
  /// This value is always non-empty, in lowercase, and contains only letters.
  final String code;

  /// How many cards are in the expansion.
  ///
  /// This number is at least 1 and _excludes_ variants, which are assigned
  /// [Card.number] values greater than this number.
  ///
  /// For example, in "Spark of Rebellion", `Director Krennic` is `001/252`, but
  /// his variant cards are `253` (Showcase) and `269` (Hyperspace).
  final int count;

  /// The cards in the expansion.
  ///
  /// The length of this list is at most [count] (typically equal to it, but
  /// pre-release expansions may not have all cards revealed).
  ///
  /// Cards must be ordered and unique by their [Card.number].
  final List<Card> cards;

  JsonObject toJson() {
    return JsonObject({
      'code': JsonString(code),
      'name': JsonString(name),
      'count': JsonNumber(count),
      'cards': JsonArray(cards.map((c) => c.toJson()).toList()),
    });
  }
}

enum Aspect {
  vigilance,
  command,
  aggression,
  cunning,
  heroism,
  villainy;

  static final _byName = {
    for (final aspect in values) aspect.name: aspect,
  };

  factory Aspect.fromName(String name) {
    final aspect = _byName[name];
    if (aspect == null) {
      throw ArgumentError.value(name, 'name', 'unknown aspect');
    }
    return aspect;
  }

  JsonString toJson() => JsonString(name);
}

/// Encapsulates between 0 and 2 aspect icons present on a card.
final class Aspects {
  static const none = Aspects._(null, null);

  final Aspect? _a;
  final Aspect? _b;

  const Aspects._(this._a, this._b);

  factory Aspects([Aspect? a, Aspect? b]) {
    if (a == null && b == null) {
      return none;
    }
    if (a == null && b != null) {
      throw ArgumentError.value(b, 'b', 'must be null if a is null');
    }
    return Aspects._(a, b);
  }

  factory Aspects.from(Iterable<Aspect> aspects) {
    final list = aspects.toList();
    if (list.isEmpty) {
      return none;
    }
    if (list.length > 2) {
      throw ArgumentError.value(
        aspects,
        'aspects',
        'must contain at most 2 elements',
      );
    }
    return Aspects._(list[0], list.length > 1 ? list[1] : null);
  }

  Iterable<Aspect> get values => _a == null
      ? const []
      : _b == null
          ? List.unmodifiable([_a])
          : List.unmodifiable([_a, _b]);

  @override
  bool operator ==(Object other) {
    return other is Aspects && other._a == _a && other._b == _b;
  }

  @override
  int get hashCode => Object.hash(_a, _b);

  JsonArray toJson() {
    return JsonArray(values.map((a) => a.toJson()).toList());
  }

  @override
  String toString() {
    final desc = values.isEmpty
        ? 'None'
        : values.map((s) => s.name.capitalize()).join(', ');
    return 'Aspects <$desc>';
  }
}

/// Represents a card's rarity.
enum Rarity {
  common,
  uncommon,
  rare,
  legendary,
  special;

  static final _byName = {
    for (final rarity in values) rarity.name: rarity,
  };

  factory Rarity.fromName(String name) {
    final rarity = _byName[name];
    if (rarity == null) {
      throw ArgumentError.value(name, 'name', 'unknown rarity');
    }
    return rarity;
  }

  String get character => name[0];

  JsonString toJson() => JsonString(name);
}

/// Represents any card in the game, regardless of type.
///
/// An art _variant_ of an existing card is tracked separately, see [Variant].
sealed class Card {
  Card({
    required this.title,
    required this.number,
    required this.rarity,
    required this.aspects,
  }) {
    _checkNotEmpty(title, 'title');
    _checkAtLeast1(number, 'number');
  }

  factory Card.fromJson(JsonObject json) {
    final kind = _CardKind.fromName(json['kind'].as());
    return kind.parseJson(json);
  }

  /// Number of the card.
  ///
  /// At least 1, and at most [Expansion.cardCount].
  @nonVirtual
  final int number;

  /// Serialized tag for the card type.
  _CardKind get _kind;

  /// Title of the card.
  ///
  /// This value is always non-empty.
  @nonVirtual
  final String title;

  /// Rarity of the card.
  @nonVirtual
  final Rarity rarity;

  /// Aspects of the card.
  @nonVirtual
  final Aspects aspects;

  @mustBeOverridden
  JsonObject toJson() {
    return JsonObject({
      'number': JsonNumber(number),
      'kind': JsonString(_kind.name),
      'title': JsonString(title),
      'rarity': rarity.toJson(),
      'aspects': aspects.toJson(),
    });
  }
}

/// A tag that provides a way to track the serialized state of [Card] data.
enum _CardKind {
  base(BaseCard.fromJson),
  event(EventCard.fromJson),
  leader(LeaderCard.fromJson),
  unit(UnitCard.fromJson),
  upgrade(UpgradeCard.fromJson);

  final Card Function(JsonObject) _parser;

  static final _byName = {
    for (final type in values) type.name: type,
  };

  const _CardKind(this._parser);

  factory _CardKind.fromName(String name) {
    final type = _byName[name];
    if (type == null) {
      throw ArgumentError.value(name, 'name', 'unknown card type');
    }
    return type;
  }

  Card parseJson(JsonObject json) => _parser(json);
}

/// A base.
final class BaseCard extends Card {
  BaseCard({
    required super.number,
    required super.title,
    required super.rarity,
    required super.aspects,
    required this.health,
  });

  factory BaseCard.fromJson(JsonObject json) {
    return BaseCard(
      number: json['number'].as(),
      title: json['title'].as(),
      rarity: Rarity.fromName(json['rarity'].as()),
      aspects: Aspects.from(
        json['aspects'].array().cast<JsonString>().map(Aspect.fromName),
      ),
      health: json['health'].as(),
    );
  }

  /// Amount of health points the base has.
  @nonVirtual
  final int health;

  @override
  _CardKind get _kind => _CardKind.base;

  @override
  JsonObject toJson() {
    return JsonObject({
      ...super.toJson(),
      'health': JsonNumber(health),
    });
  }
}

/// A card that is part of a player's draw deck or hand.
///
/// A synthetic type that includes all cards except bases or tokens.
sealed class DeckCard extends Card {
  DeckCard({
    required super.number,
    required super.title,
    required super.rarity,
    required super.aspects,
    required this.cost,
  }) {
    _checkAtLeast0(cost, 'cost');
  }

  /// Cost of the card.
  ///
  /// This value is at least 0.
  @nonVirtual
  final int cost;

  @mustBeOverridden
  @override
  JsonObject toJson() {
    return JsonObject({
      ...super.toJson(),
      'cost': JsonNumber(cost),
    });
  }
}

/// A deployable card.
///
/// A synthetic type that represnts a card that can be deployed to the game
/// board (i.e. share various attributes such as [cost] or [health]).
sealed class ArenaCard extends DeckCard {
  ArenaCard({
    required super.number,
    required super.title,
    required super.rarity,
    required super.aspects,
    required super.cost,
    required this.health,
    required this.power,
  }) {
    _checkAtLeast0(health, 'health');
    _checkAtLeast0(power, 'power');
  }

  /// Health points of the card.
  ///
  /// This value is at least 1.
  final int health;

  /// Power of the card.
  ///
  /// This value is at least 0.
  final int power;

  /// Subtitle of the card.
  ///
  /// If present, this value is always non-empty.
  String? get subTitle;

  @override
  JsonObject toJson() {
    return JsonObject({
      ...super.toJson(),
      'health': JsonNumber(health),
      'power': JsonNumber(power),
      'sub_title': JsonAny.from(subTitle),
    });
  }
}

/// A leader card.
final class LeaderCard extends ArenaCard {
  LeaderCard({
    required super.number,
    required super.title,
    required super.rarity,
    required super.aspects,
    required this.subTitle,
    required super.cost,
    required super.health,
    required super.power,
  });

  factory LeaderCard.fromJson(JsonObject json) {
    return LeaderCard(
      number: json['number'].as(),
      title: json['title'].as(),
      rarity: Rarity.fromName(json['rarity'].as()),
      aspects: Aspects.from(
        json['aspects'].array().cast<JsonString>().map(Aspect.fromName),
      ),
      subTitle: json['sub_title'].as(),
      cost: json['cost'].as(),
      health: json['health'].as(),
      power: json['power'].as(),
    );
  }

  /// Subtitle of the card.
  @override
  final String subTitle;

  @override
  _CardKind get _kind => _CardKind.leader;

  @override
  JsonObject toJson() {
    return JsonObject({
      ...super.toJson(),
    });
  }
}

/// A unit card.
final class UnitCard extends ArenaCard {
  UnitCard({
    required super.number,
    required super.title,
    required this.subTitle,
    required super.rarity,
    required super.aspects,
    required super.cost,
    required super.health,
    required super.power,
  });

  factory UnitCard.fromJson(JsonObject json) {
    return UnitCard(
      number: json['number'].as(),
      title: json['title'].as(),
      subTitle: json['sub_title'].asOrNull(),
      rarity: Rarity.fromName(json['rarity'].as()),
      aspects: Aspects.from(
        json['aspects'].array().cast<JsonString>().map(Aspect.fromName),
      ),
      cost: json['cost'].as(),
      health: json['health'].as(),
      power: json['power'].as(),
    );
  }

  @override
  _CardKind get _kind => _CardKind.unit;

  /// Subtitle of the card.
  @override
  final String? subTitle;

  @override
  JsonObject toJson() {
    return JsonObject({
      ...super.toJson(),
    });
  }
}

/// An upgrade card.
final class UpgradeCard extends DeckCard {
  UpgradeCard({
    required super.number,
    required super.title,
    required super.rarity,
    required super.aspects,
    required super.cost,
  });

  factory UpgradeCard.fromJson(JsonObject json) {
    return UpgradeCard(
      number: json['number'].as(),
      title: json['title'].as(),
      rarity: Rarity.fromName(json['rarity'].as()),
      aspects: Aspects.from(
        json['aspects'].array().cast<JsonString>().map(Aspect.fromName),
      ),
      cost: json['cost'].as(),
    );
  }

  @override
  _CardKind get _kind => _CardKind.upgrade;

  @override
  JsonObject toJson() {
    return JsonObject({
      ...super.toJson(),
    });
  }
}

/// An event card.
final class EventCard extends DeckCard {
  EventCard({
    required super.number,
    required super.title,
    required super.rarity,
    required super.aspects,
    required super.cost,
  });

  factory EventCard.fromJson(JsonObject json) {
    return EventCard(
      number: json['number'].as(),
      title: json['title'].as(),
      rarity: Rarity.fromName(json['rarity'].as()),
      aspects: Aspects.from(
        json['aspects'].array().cast<JsonString>().map(Aspect.fromName),
      ),
      cost: json['cost'].as(),
    );
  }

  @override
  _CardKind get _kind => _CardKind.event;

  @override
  JsonObject toJson() {
    return JsonObject({
      ...super.toJson(),
    });
  }
}
