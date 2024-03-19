import 'package:meta/meta.dart';

@immutable
sealed class Card {
  Card({
    required this.name,
    required this.unique,
  });

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
}

@immutable
sealed class DeckCard extends Card {
  DeckCard({
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
