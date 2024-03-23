import 'package:meta/meta.dart';
import 'package:unlimited/core.dart';

/// A minimal representation of a card that retains identity.
///
/// This class is used to refer to a card without needing exact details about
/// the card itself. It is used in cases where a card's details are not needed,
/// such as for storage in a database or for a player's decklist.
///
/// ## Equality
///
/// Two card references are considered equal if:
/// - They belong to the same [expansion];
/// - They have the same [number];
/// - They are both [foil] or both _aren't_ [foil].
///
/// To ignore [foil] when comparing two card references, use [withFoil].
///
/// ## Comparison
///
/// See [CardReference.compareTo] for details on how card references are sorted.
///
/// ## Example
///
/// ```dart
/// final a = CardReference(expansion: 'ABC', number: 1);
/// final b = CardReference(expansion: 'ABC', number: 1);
/// print(a == b); // true
///
/// final c = CardReference(expansion: 'ABC', number: 1, foil: true);
/// print(a == c); // false
/// print(a.withFoil() == c.withFoil()); // true
/// ```
@immutable
final class CardReference implements Comparable<CardReference> {
  /// Creates a new card reference.
  ///
  /// Optionally, [foil] can be set to `true`.
  const CardReference({
    required this.expansion,
    required this.number,
    this.foil = false,
  });

  /// A reference to an [Expansion.code].
  ///
  /// Must be non-empty.
  final String expansion;

  /// A reference to a [Card.number] within the [expansion].
  ///
  /// Must be at least 1.
  final int number;

  /// Whether this card is a foil.
  final bool foil;

  /// Compares this card reference to another.
  ///
  /// The comparison is done by comparing [expansion] first, then [number], and
  /// finally [foil] (with non-foil cards coming before foil cards).
  @override
  int compareTo(CardReference other) {
    if (expansion.compareTo(other.expansion) case final x when x != 0) {
      return x;
    }
    if (number.compareTo(other.number) case final x when x != 0) {
      return x;
    }
    if (foil == other.foil) {
      return 0;
    }
    return foil ? 1 : -1;
  }

  /// Returns the same card reference, but with [foil] set explicitly.
  CardReference withFoil({bool foil = true}) {
    if (foil == this.foil) {
      return this;
    }
    return CardReference(
      expansion: expansion,
      number: number,
      foil: foil,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CardReference &&
        expansion == other.expansion &&
        number == other.number &&
        foil == other.foil;
  }

  @override
  int get hashCode => Object.hash(expansion, number, foil);

  @override
  String toString() {
    final number = '${this.number}'.padLeft(3, '0');
    return '${expansion.toUpperCase()} $number${foil ? ' (Foil)' : ''}';
  }
}

/// _Any_ card in Star Wars: Unlimited, with a sealed hierarchy of card types.
///
/// The hierarchy is sealed as the following:
/// ```txt
/// Card
/// ├── LeaderCard
/// ├── BaseCard
/// ├── TokenCard
/// └── PlayableCard
///       ├── UnitCard
///       ├── UpgradeCard
///       └── EventCard
/// ```
///
/// In addition, [ArenaCard], [DeckCard], [TargetCard], [AttachmentCard] are
/// sealed interfaces that are implemented by some of the above classes in order
/// to indicate shared behavior.
///
/// ## Equality
///
/// Two cards are considered equal if they:
/// - Both are [TokenCard]s or both _aren't_ [TokenCard]s;
/// - Have the same [expansion] and [number].
@immutable
sealed class Card implements Comparable<Card> {
  const Card({
    required this.expansion,
    required this.number,
    required this.name,
    required this.subTitle,
    required this.unique,
    required this.aspects,
    required this.rarity,
  });

  /// Which release this card is from.
  final Expansion expansion;

  /// Card number within the [expansion].
  ///
  /// Must be at least 1.
  final int number;

  /// Name of the card.
  ///
  /// Regardless of its printed language, a card's name is considered to be the
  /// English version of its name.
  ///
  /// Must be non-empty.
  final String name;

  /// Subtitle of the card, if any.
  final String? subTitle;

  /// Whether the card is unique.
  ///
  /// If a unique card has the same [number] as another unique card, it is
  /// considered to be the same card. A player can only control one copy of each
  /// unique card at a given time.
  ///
  /// If a player ever has more than one copy of a unique card under their
  /// control at a given time, they must defeat one of them, resolving any
  /// abilities that trigger upon either copy being played or defeated.
  final bool unique;

  /// Which aspect icons are present on the card.
  final Aspects aspects;

  /// The rarity of this card.
  final Rarity rarity;

  @override
  @nonVirtual
  bool operator ==(Object other) {
    if (other is! Card) {
      return false;
    }

    // A token card is only equal to itself.
    if (other is TokenCard) {
      return this is TokenCard &&
          expansion == other.expansion &&
          number == other.number;
    }

    // Otherwise, compare set and number.
    return expansion == other.expansion && number == other.number;
  }

  @override
  @nonVirtual
  int get hashCode => Object.hash(expansion, number);

  @override
  int compareTo(Card other) {
    if (expansion.compareTo(other.expansion) case final x when x != 0) {
      return x;
    }
    return number.compareTo(other.number);
  }

  @override
  String toString() {
    return '$name <${expansion.code.toUpperCase()} $number>';
  }

  /// Returns a [CardReference] to this card.
  ///
  /// A reference is a lightweight object that retains the identity of a card
  /// without needing to store the card's details. It is useful for storage in a
  /// database or for a player's decklist.
  CardReference toReference({bool foil = false}) {
    return CardReference(
      expansion: expansion.code,
      number: number,
      foil: foil,
    );
  }
}

/// The "leader" side of a leader/leader [unit] card.
@immutable
final class LeaderCard extends Card {
  /// Creates a new leader card.
  LeaderCard({
    required super.expansion,
    required super.number,
    required super.name,
    required super.subTitle,
    required super.unique,
    required super.aspects,
    required super.rarity,
    required this.unit,
  });

  /// The reverse, leader unit side of this card.
  final LeaderUnitCard unit;
}

/// A base card.
@immutable
final class BaseCard extends Card implements TargetCard {
  /// Creates a new base card.
  const BaseCard({
    required super.expansion,
    required super.number,
    required super.name,
    required super.aspects,
    required super.rarity,
    required this.health,
  }) : super(unique: false, subTitle: null);

  @override
  final int health;

  /// Bases are not _played_, therefore they are not considered _unique_.
  ///
  /// _Technically it would be better to not even expose this property, but it
  /// simplifies the card hierarchy to have it here (we already have enough
  /// sealed classes as it is)._
  @override
  bool get unique => false;

  /// Bases do not have a subtitle.
  ///
  /// _Technically it would be better to not even expose this property, but it
  /// simplifies the card hierarchy to have it here (we already have enough
  /// sealed classes as it is)._
  @override
  Null get subTitle => null;
}

/// Any card that is playable during a game.
///
/// In other words, everything but a [BaseCard].
sealed class PlayableCard extends Card {
  PlayableCard({
    required super.expansion,
    required super.number,
    required super.name,
    required super.unique,
    required super.aspects,
    required super.rarity,
    required super.subTitle,
    required Iterable<Trait> traits,
    required this.cost,
  }) : traits = Set.unmodifiable(traits);

  /// Traits present on the card.
  ///
  /// Must be non-empty.
  final Set<Trait> traits;

  /// Number of resources that must be exhausted in order to play this card.
  ///
  /// A card's cost cannot be modified below 0. If an abiility would cause the
  /// cost of a card to be modified below, treat that card as having 0 cost
  /// instead.
  final int cost;
}

/// Sealed interface for card types that can be present in a player's deck.
@immutable
sealed class DeckCard implements Card {}

/// Sealed interface for card types that can be present in an [arena].
@immutable
sealed class ArenaCard extends PlayableCard implements TargetCard {
  ArenaCard({
    required super.expansion,
    required super.number,
    required super.name,
    required super.unique,
    required super.aspects,
    required super.rarity,
    required super.subTitle,
    required super.traits,
    required super.cost,
    required this.arena,
    required this.power,
    required this.health,
  });

  /// Which arena this card is played in.
  final Arena arena;

  /// The attack power of this card.
  ///
  /// Must be at least 0.
  final int power;

  /// The health of this card.
  ///
  /// Must be at least 0.
  @override
  final int health;
}

/// Sealed interface for card types that can receive damage.
sealed class TargetCard implements Card {
  /// The health of this card.
  ///
  /// Must be at least 0.
  int get health;
}

/// The unit side of a [LeaderCard].
///
/// This card, despite the name, is not a [UnitCard].
final class LeaderUnitCard extends ArenaCard implements TargetCard {
  /// Creates a new leader unit card.
  LeaderUnitCard({
    required super.expansion,
    required super.number,
    required super.name,
    required super.unique,
    required super.aspects,
    required super.rarity,
    required super.subTitle,
    required super.traits,
    required super.cost,
    required super.power,
    required super.health,
    super.arena = Arena.ground,
  });
}

/// A unit card (specifically _unit_, not a [LeaderUnitCard]).
@immutable
final class UnitCard extends ArenaCard implements DeckCard, TargetCard {
  /// Creates a new unit card.
  UnitCard({
    required super.expansion,
    required super.number,
    required super.name,
    required super.unique,
    required super.aspects,
    required super.rarity,
    required super.subTitle,
    required super.arena,
    required super.traits,
    required super.cost,
    required super.power,
    required super.health,
  });
}

/// A sealed interface for card types that can be attached to other cards.
@immutable
sealed class AttachmentCard implements Card {
  /// The power modifier of this card.
  ///
  /// Must be at least 0.
  int get powerModifier;

  /// The health modifier of this card.
  ///
  /// Must be at least 0.
  int get healthModifier;
}

/// A card that can be played to be attached to a unit card.
@immutable
final class UpgradeCard extends PlayableCard
    implements DeckCard, AttachmentCard {
  /// Creates a new upgrade card.
  UpgradeCard({
    required super.expansion,
    required super.number,
    required super.name,
    required super.unique,
    required super.aspects,
    required super.rarity,
    required super.traits,
    required super.cost,
    this.powerModifier = 0,
    this.healthModifier = 0,
  }) : super(subTitle: null);

  @override
  final int powerModifier;

  @override
  final int healthModifier;

  /// Events never have a subtitle.
  ///
  /// _Technically it would be better to not even expose this property, but it
  /// simplifies the card hierarchy to have it here (we already have enough
  /// sealed classes as it is)._
  @override
  Null get subTitle => null;
}

/// A card that represents a token attached to a unit card.
@immutable
final class TokenCard extends Card implements AttachmentCard {
  /// Creates a new token card.
  TokenCard({
    required super.expansion,
    required super.number,
    required super.name,
    required super.unique,
    required super.aspects,
    required super.rarity,
    this.powerModifier = 0,
    this.healthModifier = 0,
  }) : super(subTitle: null);

  @override
  final int powerModifier;

  @override
  final int healthModifier;

  /// Tokens never have a subtitle.
  ///
  /// _Technically it would be better to not even expose this property, but it
  /// simplifies the card hierarchy to have it here (we already have enough
  /// sealed classes as it is)._
  @override
  Null get subTitle => null;

  @override
  String toString() {
    return '$name <${expansion.code.toUpperCase()} T$number>';
  }
}

/// Represents an event card that exists in a player's deck.
@immutable
final class EventCard extends PlayableCard implements DeckCard {
  /// Creates a new event card.
  EventCard({
    required super.expansion,
    required super.number,
    required super.name,
    required super.unique,
    required super.aspects,
    required super.rarity,
    required super.traits,
    required super.cost,
  }) : super(subTitle: null);

  /// Events never have a subtitle.
  ///
  /// _Technically it would be better to not even expose this property, but it
  /// simplifies the card hierarchy to have it here (we already have enough
  /// sealed classes as it is)._
  @override
  Null get subTitle => null;
}

/// Extension methods for [Iterable]s of [DeckCard]s.
extension IterableDeckCard on Iterable<DeckCard> {
  /// Returns the cards grouped by how many copies of each card are present.
  Map<DeckCard, int> groupByCopies() {
    final map = <DeckCard, int>{};
    for (final card in this) {
      map[card] = (map[card] ?? 0) + 1;
    }
    return map;
  }
}
