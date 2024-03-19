sealed class Card {
  Card({
    required this.name,
  });

  /// Name of the card.
  final String name;
}

final class Base extends Card {}

final class Leader extends Card {}
