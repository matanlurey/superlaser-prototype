import 'package:meta/meta.dart';
import 'package:unlimited/core.dart';

/// TODO: Document.
@immutable
final class Resource {
  /// Creates a new resource from the given [card].
  factory Resource.fromCard(DeckCard card) {
    return Resource._(card: card);
  }

  const Resource._({
    required this.card,
  });

  /// The card that represents the resource.
  final DeckCard card;

  @override
  bool operator ==(Object other) {
    return other is Resource && other.card == card;
  }

  @override
  int get hashCode => card.hashCode;

  @override
  String toString() => 'Resource <$card>';
}

/// TODO: Document.
@immutable
final class Base {
  /// Creates a new base from the given [card].
  factory Base.fromCard(BaseCard card) {
    return Base._(card: card);
  }

  const Base._({
    required this.card,
  });

  /// The card that represents the base.
  final BaseCard card;

  @override
  bool operator ==(Object other) {
    return other is Base && other.card == card;
  }

  @override
  int get hashCode => card.hashCode;

  @override
  String toString() => 'Base <$card>';
}

/// TODO: Document.
@immutable
final class Leader {
  /// Creates a new leader from the given [card].
  factory Leader.fromCard(LeaderCard card) {
    return Leader._(card: card);
  }

  const Leader._({
    required this.card,
  });

  /// The card that represents the leader.
  final LeaderCard card;

  @override
  bool operator ==(Object other) {
    return other is Leader && other.card == card;
  }

  @override
  int get hashCode => card.hashCode;

  @override
  String toString() => 'Leader <$card>';
}

/// TODO: Document.
@immutable
final class Unit {
  /// Creates a new unit from the given [card].
  factory Unit.fromCard(ArenaCard card) {
    return Unit._(card: card);
  }

  const Unit._({
    required this.card,
  });

  /// The card that represents the unit or leader unit.
  final ArenaCard card;

  @override
  bool operator ==(Object other) {
    return other is Unit && other.card == card;
  }

  @override
  int get hashCode => card.hashCode;

  @override
  String toString() => 'Unit <$card>';
}
