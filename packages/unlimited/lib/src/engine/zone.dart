import 'dart:math';

import 'package:meta/meta.dart';
import 'package:unlimited/core.dart';
import 'package:unlimited/engine.dart';

/// Consists of all[^1] cards that a [player] controls in [Zone.inPlay] zones.
///
/// A player's play area includes cards in that player's [baseZone], cards in
/// that player's [resourceZone], units that the player controls in the
/// [groundUnits] or [spaceUnits], and any upgrades attached to units that the
/// player controls.
///
/// [^1]: With the exception of any upgrades that a player controls attached to
///       enemy units (which are in the unit's controller's play area).
@immutable
final class PlayArea {
  /// Creates a new play area for the given [player].
  factory PlayArea.viewOf(
    Player player, {
    required BaseZone baseZone,
    required ResourceZone resourceZone,
    required GroundArenaZone groundArena,
    required SpaceArenaZone spaceArena,
  }) {
    return PlayArea._(
      player: player,
      baseZone: baseZone,
      resourceZone: resourceZone,
      groundUnits: groundArena.units[player] ?? const [],
      spaceUnits: spaceArena.units[player] ?? const [],
    );
  }

  const PlayArea._({
    required this.player,
    required this.baseZone,
    required this.resourceZone,
    required this.groundUnits,
    required this.spaceUnits,
  });

  /// The player that controls the cards in this play area.
  final Player player;

  /// A player's base zone.
  final BaseZone baseZone;

  /// A player's resource zone.
  final ResourceZone resourceZone;

  /// Units controlled by the player in the ground arena.
  ///
  /// The list is unmodifiable.
  final List<Unit> groundUnits;

  /// Units controlled by the player in the space arena.
  ///
  /// The list is unmodifiable.
  final List<Unit> spaceUnits;
}

/// Defines areas of the game with specific rules.
///
/// - Cards that are "set aside" are not considered to be in any zone;
/// - The "game area" refers to _all_ zones in the game collectively.
@immutable
sealed class Zone {
  /// Whether this zone is considered "in play".
  ///
  /// An "in play" zone means that, by default, they have the potential to
  /// affect the game through their abilities, power, and HP. A player controls
  /// the cards they play in these zones, or put into play in these zones.
  bool get inPlay;

  /// Whether this zone is considered "out of play".
  @nonVirtual
  bool get outOfPlay => !inPlay;
}

/// A zone that is owned by exactly one player.
@immutable
sealed class OwnedZone extends Zone {}

/// Each player has their own base zone.
///
/// The [base] always remain in their owner's base zone, while [leaders] move
/// from their owner's base zone to the [GroundArenaZone] when deployed, and from
/// the [GroundArenaZone] back to their owner's base zone when defeated.
///
/// Units in their arena may attack enemy bases directly without moving zones.
@immutable
final class BaseZone extends OwnedZone {
  /// Creates a new base zone with a base and a leader.
  BaseZone({
    required this.base,
    required Iterable<Leader> leaders,
  }) : leaders = List.unmodifiable(leaders);

  /// The base that is in this zone.
  final Base base;

  /// The leader(s) that are in this zone.
  ///
  /// Leaders are removed from the base zone when they are deployed.
  ///
  /// The list is unmodifiable.
  final List<Leader> leaders;

  @override
  bool get inPlay => true;
}

/// A zone that is shared by all players.
@immutable
sealed class SharedZone extends Zone {}

/// A shared zone where each player's ground units are played.
///
/// Friendly ground units can attack enemy ground units in the ground arena,
/// as well as the enemy base. They do not leave the ground arena when attacking
/// the enemy base.
///
/// Ground units cannot attack enemy units in the space arena unless an ability
/// specifically allows it. However, ground units may be able to deal damage to
/// units in the space arena through abilities.
@immutable
final class GroundArenaZone extends SharedZone {
  /// Creates a new ground arena with no units.
  factory GroundArenaZone() => GroundArenaZone._(const {});

  /// Creates a new ground arena with the given [units], grouped by [Player].
  ///
  /// Each [ArenaCard.arena] must be [Arena.ground].
  ///
  /// The order of units in the list is the order in which they were deployed,
  /// and is significant in order to determine which unit (for duplicate cards)
  /// is being targeted by an effect.
  factory GroundArenaZone.withUnits(Map<Player, List<Unit>> units) {
    return GroundArenaZone._(Map.from(units));
  }

  GroundArenaZone._(this.units) {
    for (final units in units.entries) {
      for (final unit in units.value) {
        if (unit.card.arena != Arena.ground) {
          throw ArgumentError.value(
            unit,
            'units',
            'Unit owned by ${units.key} is not a ground unit',
          );
        }
      }
    }
  }

  /// The units in this arena, grouped by [Player].
  ///
  /// The order of units in the list is the order in which they were deployed,
  /// and is significant in order to determine which unit (for duplicate cards)
  /// is being targeted by an effect.
  ///
  /// The map is unmodifiable.
  final Map<Player, List<Unit>> units;

  @override
  bool get inPlay => true;
}

/// A shared zone where each player's space units are played.
///
/// Friendly space units can attack enemy space units in the space arena, as
/// well as the enemy base. They do not leave the space arena when attacking the
/// enemy base.
///
/// Space units cannot attack enemy units in the ground arena unless an ability
/// specifically allows it. However, space units may be able to deal damage to
/// units in the ground arena through abilities.
@immutable
final class SpaceArenaZone extends SharedZone {
  /// Creates a new space arena with no units.
  factory SpaceArenaZone() => SpaceArenaZone._(const {});

  /// Creates a new space arena with the given [units], grouped by [Player].
  ///
  /// Each [ArenaCard.arena] must be [Arena.space].
  ///
  /// The order of units in the list is the order in which they were deployed,
  /// and is significant in order to determine which unit (for duplicate cards)
  /// is being targeted by an effect.
  factory SpaceArenaZone.withUnits(Map<Player, List<Unit>> units) {
    return SpaceArenaZone._(Map<Player, List<Unit>>.unmodifiable(units));
  }

  SpaceArenaZone._(this.units) {
    for (final units in units.entries) {
      for (final unit in units.value) {
        if (unit.card.arena != Arena.space) {
          throw ArgumentError.value(
            unit,
            'units',
            'Unit owned by ${units.key} is not a space unit',
          );
        }
      }
    }
  }

  /// The units in this arena, grouped by [Player].
  ///
  /// The order of units in the list is the order in which they were deployed,
  /// and is significant in order to determine which unit (for duplicate cards)
  /// is being targeted by an effect.
  ///
  /// The map is unmodifiable.
  final Map<Player, List<Unit>> units;

  @override
  bool get inPlay => true;
}

/// Each player has their own resource zone.
///
/// Cards in a resource zone are called [resources], which can be exhausted to
/// pay the costs of other cards. Resources are placed facedown and remain
/// facedown while in a resource zone. The owner may view facedown resources
/// they control at any time, but is hidden information for their opponent.
///
/// Players can choose to add a card from their hand to their resource zone
/// during each regroup phase.
@immutable
final class ResourceZone extends OwnedZone {
  /// Creates a new empty resource zone.
  ResourceZone() : resources = const [];

  /// Creates a new resource zone with the given cards.
  ResourceZone.withResources(
    Iterable<Resource> resources,
  ) : resources = List.unmodifiable(resources);

  /// The resources in this zone, in the order they were added.
  ///
  /// The list is unmodifiable.
  final List<Resource> resources;

  @override
  bool get inPlay => true;
}

/// Each player's deck is its own zone.
///
/// By default, cards in a player's deck are facedown, out of play and cannot be
/// viewed except through abilities. The cards in a player's deck are considered
/// hidden information for both players.
///
/// Cards in a deck leave the deck when they are drawn, discarded, or played
/// directly from the deck. A card is not considered to leave the dek when
/// searched, looked at, or revealed from the deck (unless it is immediately
/// drawn, discarded, or played).
@immutable
final class DeckZone extends OwnedZone {
  /// Creates a new deck zone with the given cards.
  DeckZone.withCards(
    Iterable<DeckCard> cards,
  ) : cards = List.unmodifiable(cards);

  /// The cards in this zone, from top to bottom.
  ///
  /// The list is unmodifiable.
  final List<DeckCard> cards;

  @override
  bool get inPlay => false;

  /// Returns a new deck zone with the drawn card removed.
  ///
  /// The [fn] function is called with the drawn card.
  ///
  /// If the deck is empty, throws a [StateError].
  @useResult
  DeckZone draw(void Function(DeckCard) fn) {
    if (cards.isEmpty) {
      throw StateError('Cannot draw from an empty deck');
    }
    final copy = [...cards];
    fn(cards.removeAt(0));
    return DeckZone.withCards(copy);
  }

  /// Returns a new deck zone with the given cards shuffled.
  @useResult
  DeckZone shuffle([Random? random]) {
    return DeckZone.withCards([...cards]..shuffle(random));
  }
}

/// Each player's hand is its own zone.
///
/// A player can have any number of cards in their hand.
///
/// Cards enter a player's hand when a player draws them from their deck, or
/// when an ability returns a card from another zone to their hand. Cards leave
/// a player's hand when played or discarded. A card is not considered to leave
/// a player's hand when looked at or revealed (unless it is immediately
/// played or discarded).
///
/// The cards in a player's hand may be looked at only by that player, and the
/// faceup sides of those cards are considered hidden information for that
/// player's opponent. The number of cards in a player's hand is considered
/// open information.
@immutable
final class HandZone extends OwnedZone {
  /// Creates a new empty hand zone.
  HandZone() : cards = const [];

  /// Creates a new hand zone with the given cards.
  HandZone.withCards(
    Iterable<DeckCard> cards,
  ) : cards = List.unmodifiable(cards);

  /// The cards in the player's hand, in the order they were drawn.
  ///
  /// The list is unmodifiable.
  final List<DeckCard> cards;

  @override
  bool get inPlay => false;
}

/// Each player's discard pile is its own zone.
///
/// Played events, defeated (non-leader) units, defeated upgrades, and discarded
/// cards placed in a player's discard pile, faceup. Cards in a player's discard
/// pile are considered open information and can be viewed by any player at any
/// time.
///
/// The order of cards in a discard pile does not need to be maintained; a
/// player may rearrange the cards in their discard pile at any time.
///
/// If an ability allows a player to play a card from their discard pile, they
/// must still pay all costs for the card, accounting for any modifiers and
/// additional costs applied to the card.
@immutable
final class DiscardPileZone extends OwnedZone {
  /// Creates a new empty discard pile.
  DiscardPileZone() : cards = const [];

  /// Creates a new discard pile with the given cards.
  DiscardPileZone.withCards(
    Iterable<DeckCard> cards,
  ) : cards = List.unmodifiable(cards);

  /// The cards in the discard pile, in any order.
  ///
  /// The list is unmodifiable.
  final List<DeckCard> cards;

  @override
  bool get inPlay => false;
}
