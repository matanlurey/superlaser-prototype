import 'package:jsonut/jsonut.dart';
import 'package:meta/meta.dart';

extension on String {
  String capitalize() {
    return isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : this;
  }
}

/// Adds a `let` method to allow for chaining.
extension Let<T> on T {
  /// Allows for chaining of methods.
  ///
  /// - [f] is the function to call with `this`.
  R? let<R>(R Function(T) f) {
    return this == null ? null : f(this);
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
final class Expansion implements ToJson {
  /// Creates a new expansion.
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

  /// Parses the given JSON string into an [Expansion].
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

  @override
  JsonValue toJson() {
    return JsonObject({
      'code': JsonString(code),
      'name': JsonString(name),
      'count': JsonNumber(count),
      'cards': JsonArray(cards.map((c) => c.toJson()).toList()),
    });
  }
}

/// Represents a card's aspect.
enum Aspect implements ToJson {
  /// Represents the `Vigilance` aspect.
  vigilance,

  /// Represents the `Command` aspect.
  command,

  /// Represents the `Aggression` aspect.
  aggression,

  /// Represents the `Cunning` aspect.
  cunning,

  /// Represents the `Heroism` aspect.
  heroism,

  /// Represents the `Villainy` aspect.
  villainy;

  /// Returns the aspect with the given [name].
  factory Aspect.fromName(String name) {
    final aspect = _byName[name];
    if (aspect == null) {
      throw ArgumentError.value(name, 'name', 'unknown aspect');
    }
    return aspect;
  }

  static final _byName = {
    for (final aspect in values) aspect.name: aspect,
  };

  @override
  JsonValue toJson() => JsonString(name);
}

/// Encapsulates between 0 and 2 aspect icons present on a card.
@immutable
final class Aspects implements ToJson {
  /// Creates a new [Aspects] instance.
  factory Aspects([Aspect? a, Aspect? b]) {
    if (a == null && b == null) {
      return none;
    }
    if (a == null && b != null) {
      throw ArgumentError.value(b, 'b', 'must be null if a is null');
    }
    return Aspects._(a, b);
  }

  const Aspects._(this._a, this._b);

  /// Creates a new [Aspects] instance from the given [aspects].
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

  /// No aspects.
  static const none = Aspects._(null, null);

  final Aspect? _a;
  final Aspect? _b;

  /// The aspects present.
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

  @override
  JsonValue toJson() {
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
enum Rarity implements ToJson {
  /// Represents a common card.
  common,

  /// Represents an uncommon card.
  uncommon,

  /// Represents a rare card.
  rare,

  /// Represents a legendary card.
  legendary,

  /// Represents a special card.
  special;

  factory Rarity.fromName(String name) {
    final rarity = _byName[name];
    if (rarity == null) {
      throw ArgumentError.value(name, 'name', 'unknown rarity');
    }
    return rarity;
  }

  static final _byName = {
    for (final rarity in values) rarity.name: rarity,
  };

  /// Returns the name of the rarity.
  String get character => name[0];

  @override
  JsonValue toJson() => JsonString(name);
}

/// Represents any card in the game, regardless of type.
///
/// An art _variant_ of an existing card is tracked separately.
sealed class Card implements ToJson {
  Card({
    required this.title,
    required this.number,
    required this.rarity,
    required this.aspects,
    required this.unique,
    required this.art,
    this.variants,
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
  /// At least 1, and at most [Expansion.count].
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

  /// Art of the card.
  @nonVirtual
  final Art art;

  /// Variants of the card.
  @nonVirtual
  final Variants? variants;

  /// Whether this card is unique.
  @nonVirtual
  final bool unique;

  @mustBeOverridden
  @override
  JsonObject toJson() {
    return JsonObject({
      'number': JsonNumber(number),
      'kind': JsonString(_kind.name),
      'title': JsonString(title),
      'rarity': rarity.toJson(),
      'aspects': aspects.toJson(),
      'unique': JsonBoolean(unique),
      'art': art.toJson(),
      if (variants case final Variants variants) 'variants': variants.toJson(),
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

  const _CardKind(this._parser);

  factory _CardKind.fromName(String name) {
    final type = _byName[name];
    if (type == null) {
      throw ArgumentError.value(name, 'name', 'unknown card type');
    }
    return type;
  }

  final Card Function(JsonObject) _parser;

  static final _byName = {
    for (final type in values) type.name: type,
  };

  Card parseJson(JsonObject json) => _parser(json);
}

/// A base.
final class BaseCard extends Card {
  /// Creates a new base card.
  BaseCard({
    required super.number,
    required super.title,
    required super.rarity,
    required super.aspects,
    required super.unique,
    required super.art,
    required super.variants,
    required this.health,
  });

  /// Parses the given JSON string into a [BaseCard].
  factory BaseCard.fromJson(JsonObject json) {
    return BaseCard(
      number: json['number'].as(),
      title: json['title'].as(),
      art: Art.fromJson(json['art'].as()),
      variants: json['variants'].objectOrNull()?.let(Variants.fromJson),
      rarity: Rarity.fromName(json['rarity'].as()),
      aspects: Aspects.from(
        json['aspects'].array().cast<JsonString>().map(Aspect.fromName),
      ),
      unique: json['unique'].as(),
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
    required this.traits,
    required super.unique,
    required super.art,
    required super.variants,
    required this.cost,
  }) {
    _checkAtLeast0(cost, 'cost');
  }

  /// Cost of the card.
  ///
  /// This value is at least 0.
  @nonVirtual
  final int cost;

  /// Traits on the card.
  @nonVirtual
  final Set<String> traits;

  @mustBeOverridden
  @override
  JsonObject toJson() {
    return JsonObject({
      ...super.toJson(),
      'traits': JsonArray(traits.map(JsonString.new).toList()),
      'cost': JsonNumber(cost),
    });
  }
}

/// Represents a card's arena.
enum Arena implements ToJson {
  /// The battlefield.
  ground,

  /// The space.
  space;

  factory Arena.fromName(String name) {
    final arena = _byName[name];
    if (arena == null) {
      throw ArgumentError.value(name, 'name', 'unknown arena');
    }
    return arena;
  }

  static final _byName = {
    for (final arena in values) arena.name: arena,
  };

  @override
  JsonValue toJson() => JsonString(name);
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
    required super.traits,
    required super.cost,
    required super.art,
    required super.variants,
    required super.unique,
    required this.arena,
    required this.health,
    required this.power,
  }) {
    _checkAtLeast0(health, 'health');
    _checkAtLeast0(power, 'power');
  }

  /// Arena of the card.
  final Arena arena;

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
      'arena': arena.toJson(),
      'sub_title': JsonAny.from(subTitle),
    });
  }
}

/// A leader card.
final class LeaderCard extends ArenaCard {
  /// Creates a new leader card.
  LeaderCard({
    required super.number,
    required super.title,
    required super.rarity,
    required super.aspects,
    required super.traits,
    required super.art,
    required super.variants,
    required super.unique,
    required this.subTitle,
    required super.arena,
    required super.cost,
    required super.health,
    required super.power,
  });

  /// Parses the given JSON string into a [LeaderCard].
  factory LeaderCard.fromJson(JsonObject json) {
    return LeaderCard(
      number: json['number'].as(),
      title: json['title'].as(),
      art: Art.fromJson(json['art'].as()),
      variants: json['variants'].objectOrNull()?.let(Variants.fromJson),
      rarity: Rarity.fromName(json['rarity'].as()),
      aspects: Aspects.from(
        json['aspects'].array().cast<JsonString>().map(Aspect.fromName),
      ),
      traits: json['traits'].array().cast<JsonString>().toSet(),
      unique: json['unique'].as(),
      arena: Arena.fromName(json['arena'].as()),
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
  /// Creates a new unit card.
  UnitCard({
    required super.number,
    required super.title,
    required super.art,
    required super.variants,
    required this.subTitle,
    required super.rarity,
    required super.unique,
    required super.aspects,
    required super.traits,
    required super.arena,
    required super.cost,
    required super.health,
    required super.power,
  });

  /// Parses the given JSON string into a [UnitCard].
  factory UnitCard.fromJson(JsonObject json) {
    return UnitCard(
      number: json['number'].as(),
      title: json['title'].as(),
      art: Art.fromJson(json['art'].as()),
      variants: json['variants'].objectOrNull()?.let(Variants.fromJson),
      subTitle: json['sub_title'].asOrNull(),
      rarity: Rarity.fromName(json['rarity'].as()),
      aspects: Aspects.from(
        json['aspects'].array().cast<JsonString>().map(Aspect.fromName),
      ),
      traits: json['traits'].array().cast<JsonString>().toSet(),
      unique: json['unique'].as(),
      arena: Arena.fromName(json['arena'].as()),
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
  /// Creates a new upgrade card.
  UpgradeCard({
    required super.number,
    required super.title,
    required super.art,
    required super.variants,
    required super.rarity,
    required super.unique,
    required super.aspects,
    required super.traits,
    required super.cost,
  });

  /// Parses the given JSON string into an [UpgradeCard].
  factory UpgradeCard.fromJson(JsonObject json) {
    return UpgradeCard(
      number: json['number'].as(),
      title: json['title'].as(),
      art: Art.fromJson(json['art'].as()),
      variants: json['variants'].objectOrNull()?.let(Variants.fromJson),
      rarity: Rarity.fromName(json['rarity'].as()),
      aspects: Aspects.from(
        json['aspects'].array().cast<JsonString>().map(Aspect.fromName),
      ),
      traits: json['traits'].array().cast<JsonString>().toSet(),
      unique: json['unique'].as(),
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
  /// Creates a new event card.
  EventCard({
    required super.number,
    required super.title,
    required super.art,
    required super.variants,
    required super.rarity,
    required super.unique,
    required super.aspects,
    required super.traits,
    required super.cost,
  });

  /// Parses the given JSON string into an [EventCard].
  factory EventCard.fromJson(JsonObject json) {
    return EventCard(
      number: json['number'].as(),
      title: json['title'].as(),
      rarity: Rarity.fromName(json['rarity'].as()),
      art: Art.fromJson(json['art'].as()),
      variants: json['variants'].objectOrNull()?.let(Variants.fromJson),
      aspects: Aspects.from(
        json['aspects'].array().cast<JsonString>().map(Aspect.fromName),
      ),
      traits: json['traits'].array().cast<JsonString>().toSet(),
      unique: json['unique'].as(),
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

/// Represents variants of a card.
@immutable
final class Variants implements ToJson {
  /// Creates a new variants.
  Variants({
    this.hyperspace,
    this.showcase,
  });

  /// Parses the given JSON string into a [Variants].
  factory Variants.fromJson(JsonObject json) {
    final hyperspace = json['hyperspace'].objectOrNull();
    final showcase = json['showcase'].objectOrNull();
    return Variants(
      hyperspace: hyperspace == null ? null : Variant.fromJson(hyperspace),
      showcase: showcase == null ? null : Variant.fromJson(showcase),
    );
  }

  /// Hyperspace variant of the card.
  final Variant? hyperspace;

  /// Showcase variant of the card.
  final Variant? showcase;

  @override
  JsonValue toJson() {
    return JsonObject({
      if (hyperspace case final Variant hyperspace)
        'hyperspace': hyperspace.toJson(),
      if (showcase case final Variant showcase) 'showcase': showcase.toJson(),
    });
  }
}

/// Represents a variant of a card.
///
/// ## Equality
///
/// Two variants are considered equal if they have the same [number].
@immutable
final class Variant implements ToJson {
  /// Creates a new variant.
  Variant({
    required this.number,
    required this.art,
  });

  /// Parses the given JSON string into a [Variant].
  factory Variant.fromJson(JsonObject json) {
    return Variant(
      number: json['number'].as(),
      art: Art.fromJson(json['art'].as()),
    );
  }

  /// Card number of the variant.
  final int number;

  /// Art of the variant.
  final Art art;

  @override
  bool operator ==(Object other) {
    return other is Variant && other.number == number;
  }

  @override
  int get hashCode => number;

  @override
  JsonValue toJson() {
    return JsonObject({
      'number': JsonNumber(number),
      'art': art.toJson(),
    });
  }
}

/// Represents the art of a card.
@immutable
final class Art implements ToJson {
  /// Creates a new art.
  Art({
    required this.artist,
    required this.front,
    required this.back,
    required this.thumbnail,
  }) {
    _checkNotEmpty(artist, 'artist');
  }

  /// Parses the given JSON string into an [Art].
  factory Art.fromJson(JsonObject json) {
    final back = json['back'].objectOrNull();
    return Art(
      artist: json['artist'].as(),
      front: ArtImage.fromJson(json['front'].object()),
      back: back == null ? null : ArtImage.fromJson(back),
      thumbnail: ArtImage.fromJson(json['thumbnail'].object()),
    );
  }

  /// Artist of the image.
  ///
  /// This value is always non-empty.
  final String artist;

  /// Front image of the card.
  final ArtImage front;

  /// Back image of the card, if any.
  final ArtImage? back;

  /// Thumbnail of the card.
  final ArtImage thumbnail;

  @override
  JsonValue toJson() {
    return JsonObject({
      'artist': JsonString(artist),
      'front': front.toJson(),
      if (back case final ArtImage back) 'back': back.toJson(),
      'thumbnail': thumbnail.toJson(),
    });
  }
}

/// Represents an image of a card.
@immutable
final class ArtImage implements ToJson {
  /// Creates a new art image.
  ArtImage({
    required this.url,
    required this.width,
    required this.height,
  }) {
    _checkAtLeast1(width, 'width');
    _checkAtLeast1(height, 'height');
  }

  /// Parses the given JSON string into an [ArtImage].
  factory ArtImage.fromJson(JsonObject json) {
    return ArtImage(
      url: Uri.parse(json['url'].as()),
      width: json['width'].as(),
      height: json['height'].as(),
    );
  }

  /// URL of the image.
  final Uri url;

  /// Width of the image.
  ///
  /// This value is at least 1.
  final int width;

  /// Height of the image.
  ///
  /// This value is at least 1.
  final int height;

  @override
  JsonValue toJson() {
    return JsonObject({
      'url': JsonString(url.toString()),
      'width': JsonNumber(width),
      'height': JsonNumber(height),
    });
  }
}
