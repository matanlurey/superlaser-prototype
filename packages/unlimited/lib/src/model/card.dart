import 'package:meta/meta.dart';
import 'package:unlimited/src/model/expansion.dart';

/// Represents _any_ card in Star Wars: Unlimited.
///
/// ## Equality
///
/// Two cards are considered equal if they have the same [set] and [number].
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
  bool operator ==(Object other) {
    return other is Card && set == other.set && number == other.number;
  }

  @override
  int get hashCode => Object.hash(set, number);

  @override
  String toString() {
    return '$name <${set.code.toUpperCase()} $number>';
  }
}

/// Represents a card that exists in a player's deck.
@immutable
sealed class DeckCard extends Card {
  const DeckCard({
    required super.set,
    required super.number,
    required super.name,
    required super.unique,
    required this.cost,
  });

  /// Number of resources that must be exhausted in order to play this card.
  ///
  /// A card's cost cannot be modified below 0. If an abiility would cause the
  /// cost of a card to be modified below, treat that card as having 0 cost
  /// instead.
  final int cost;
}

/// Represents a leader card.
@immutable
final class LeaderCard extends Card {
  /// Creates a new leader card.
  const LeaderCard({
    required super.set,
    required super.number,
    required super.name,
    required super.unique,
  });
}

/// Represents a base card.
@immutable
final class BaseCard extends Card {
  /// Creates a new base card.
  const BaseCard({
    required super.set,
    required super.number,
    required super.name,
    required super.unique,
  });
}
