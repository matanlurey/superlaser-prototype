import 'package:meta/meta.dart';
import 'package:unlimited/src/model/arena.dart';
import 'package:unlimited/src/model/expansion.dart';
import 'package:unlimited/src/model/trait.dart';

/// Represents _any_ card in Star Wars: Unlimited.
///
/// The hierarchy is sealed as the following:
/// ```txt
/// Card
/// ├── LeaderCard
/// ├── BaseCard
/// ├── TokenCard
/// └── ArenaCard
///     ├── LeaderUnitCard
///     └── DeckCard
///         ├── UnitCard
///         ├── UpgradeCard
///         └── EventCard
/// ```
///
/// In addition, [TargetCard], [PowerCard], [AttachmentCard] are sealed
/// interfaces that are implemented by some of the above classes in order to
/// indicate shared behavior.
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

/// Represents a card that can be present in a player's arena.
@immutable
sealed class ArenaCard extends Card {
  ArenaCard({
    required super.set,
    required super.number,
    required super.name,
    required super.unique,
    required this.arena,
    required Iterable<Trait> traits,
    required this.cost,
  }) : traits = Set.unmodifiable(traits);

  /// Which arena this card is played in.
  final Arena arena;

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
    required this.leader,
    required this.health,
    required this.power,
    super.arena = Arena.ground,
  });

  /// The reverse, leader (non-unit) side of this card.
  final LeaderCard leader;

  @override
  final int health;

  @override
  final int power;
}

/// Represents a card that exists in a player's deck.
@immutable
sealed class DeckCard extends ArenaCard {
  DeckCard({
    required super.set,
    required super.number,
    required super.name,
    required super.unique,
    required super.arena,
    required super.traits,
    required super.cost,
  });
}

/// Represents a unit card that exists in a player's deck.
@immutable
final class UnitCard extends DeckCard implements TargetCard, PowerCard {
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
final class UpgradeCard extends DeckCard implements AttachmentCard {
  /// Creates a new upgrade card.
  UpgradeCard({
    required super.set,
    required super.number,
    required super.name,
    required super.unique,
    required super.arena,
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
final class EventCard extends DeckCard {
  /// Creates a new event card.
  EventCard({
    required super.set,
    required super.number,
    required super.name,
    required super.unique,
    required super.arena,
    required super.traits,
    required super.cost,
  });
}
