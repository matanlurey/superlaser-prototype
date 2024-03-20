import 'package:meta/meta.dart';
import 'package:unlimited/core.dart';

/// Represents a reference to a card.
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
    final result = expansion.compareTo(other.expansion);
    if (result != 0) {
      return result;
    }

    final result2 = number.compareTo(other.number);
    if (result2 != 0) {
      return result2;
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

/// Represents _any_ card in Star Wars: Unlimited.
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
/// In addition, [ArenaCard], [DeckCard], [TargetCard], [PowerCard],
/// [AttachmentCard] are sealed interfaces that are implemented by some of the
/// above classes in order to indicate shared behavior.
///
/// ## Equality
///
/// Two cards are considered equal if they:
/// - Both are [TokenCard]s or both _aren't_ [TokenCard]s;
/// - Have the same [set] and [number].
@immutable
sealed class Card {
  const Card({
    required this.set,
    required this.number,
    required this.name,
    required this.unique,
  });

  /// Which set this card is from.
  final Expansion set;

  /// Card number within the [set].
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

  @override
  @nonVirtual
  bool operator ==(Object other) {
    if (other is! Card) {
      return false;
    }

    // A token card is only equal to itself.
    if (other is TokenCard) {
      return this is TokenCard && set == other.set && number == other.number;
    }

    // Otherwise, compare set and number.
    return set == other.set && number == other.number;
  }

  @override
  @nonVirtual
  int get hashCode => Object.hash(set, number);

  @override
  String toString() {
    return '$name <${set.code.toUpperCase()} $number>';
  }
}

/// Represents a leader card.
@immutable
final class LeaderCard extends Card {
  /// Creates a new leader card.
  LeaderCard({
    required super.set,
    required super.number,
    required super.name,
    required super.unique,
    required this.unit,
  });

  /// The reverse, leader unit side of this card.
  final LeaderUnitCard unit;
}

/// Represents a base card.
@immutable
final class BaseCard extends Card implements TargetCard {
  /// Creates a new base card.
  const BaseCard({
    required super.set,
    required super.number,
    required super.name,
    required super.unique,
    required this.health,
  });

  @override
  final int health;
}

/// Represents a card that can be played.
///
/// In other words, everything but a [BaseCard].
sealed class PlayableCard extends Card {
  PlayableCard({
    required super.set,
    required super.number,
    required super.name,
    required super.unique,
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

/// Marker interface for cards that can be present in a player's deck.
@immutable
sealed class DeckCard implements PlayableCard {}

/// Represents a card that exists in a player's arena.
@immutable
sealed class ArenaCard extends PlayableCard {
  ArenaCard({
    required super.set,
    required super.number,
    required super.name,
    required super.unique,
    required super.traits,
    required super.cost,
    required this.arena,
  });

  /// Which arena this card is played in.
  final Arena arena;
}

/// Represents a card that can receive damage.
sealed class TargetCard implements Card {
  /// The health of this card.
  ///
  /// Must be at least 0.
  int get health;
}

/// Represents a card that has attack power.
sealed class PowerCard implements Card {
  /// The attack power of this card.
  ///
  /// Must be at least 0.
  int get power;
}

/// Represents a _leader_ unit card that is present in a player's arena.
final class LeaderUnitCard extends ArenaCard implements TargetCard, PowerCard {
  /// Creates a new leader unit card.
  LeaderUnitCard({
    required super.set,
    required super.number,
    required super.name,
    required super.unique,
    required super.traits,
    required super.cost,
    required this.health,
    required this.power,
    super.arena = Arena.ground,
  });

  @override
  final int health;

  @override
  final int power;
}

/// Represents a unit card that exists in a player's deck.
@immutable
final class UnitCard extends ArenaCard
    implements DeckCard, TargetCard, PowerCard {
  /// Creates a new unit card.
  UnitCard({
    required super.set,
    required super.number,
    required super.name,
    required super.unique,
    required super.arena,
    required super.traits,
    required super.cost,
    required this.health,
    required this.power,
  });

  @override
  final int health;

  @override
  final int power;
}

/// Represents a card that is attached to a [UnitCard] or [LeaderUnitCard].
///
/// A _marker_ interface.
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

/// Represents an upgrade card that exists in a player's deck.
@immutable
final class UpgradeCard extends PlayableCard
    implements DeckCard, AttachmentCard {
  /// Creates a new upgrade card.
  UpgradeCard({
    required super.set,
    required super.number,
    required super.name,
    required super.unique,
    required super.traits,
    required super.cost,
    this.powerModifier = 0,
    this.healthModifier = 0,
  });

  @override
  final int powerModifier;

  @override
  final int healthModifier;
}

/// Represents a token.
@immutable
final class TokenCard extends Card implements AttachmentCard {
  /// Creates a new token card.
  TokenCard({
    required super.set,
    required super.number,
    required super.name,
    required super.unique,
    this.powerModifier = 0,
    this.healthModifier = 0,
  });

  @override
  final int powerModifier;

  @override
  final int healthModifier;

  @override
  String toString() {
    return '$name <${set.code.toUpperCase()} T$number>';
  }
}

/// Represents an event card that exists in a player's deck.
@immutable
final class EventCard extends PlayableCard implements DeckCard {
  /// Creates a new event card.
  EventCard({
    required super.set,
    required super.number,
    required super.name,
    required super.unique,
    required super.traits,
    required super.cost,
  });
}
