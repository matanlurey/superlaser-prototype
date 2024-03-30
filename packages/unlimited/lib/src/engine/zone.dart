import 'dart:math';

import 'package:meta/meta.dart';
import 'package:unlimited/core.dart';
import 'package:unlimited/engine.dart';
import 'package:unlimited/src/internal.dart';

/// A defined area of the game with specific rules.
sealed class Zone {
  /// Whether this zone is in play.
  bool get inPlay;

  /// Whether this zone is out of play.
  @nonVirtual
  bool get outOfPlay => !inPlay;
}

/// A player's base zone, where their [Base] and [Leader] start.
final class BaseZone extends Zone {
  /// Creates a new base zone with the given [base] and undeployed [leaders].
  ///
  /// The [leaders] list should not contain any duplicates (where duplicates
  /// are defined as two leaders with the same expansion and card number).
  BaseZone({
    required this.base,
    required Iterable<Leader> leaders,
  }) : _leaders = leaders.toList() {
    final seen = <CardReference>{};
    for (final leader in _leaders) {
      if (!seen.add(leader.origin.toReference(foil: false))) {
        throw ArgumentError('Duplicate leader: ${leader.origin.card}.');
      }
    }
  }

  @override
  bool get inPlay => true;

  /// The player's base.
  final Base base;

  /// The player's undeployed leaders.
  ///
  /// This list can only be modified by [addLeader] and [removeLeader].
  late final leaders = List<Leader>.unmodifiable(_leaders);
  final List<Leader> _leaders;

  /// Adds a [leader] to the player's base zone.
  ///
  /// This method typically would be called when a leader unit is defeated
  /// and returns to the base zone.
  ///
  /// Throws if the leader is already in the base zone.
  void addLeader(Leader leader) {
    for (final existing in _leaders) {
      final a = existing.origin.toReference(foil: false);
      final b = leader.origin.toReference(foil: false);
      if (a == b) {
        throw ArgumentError('Leader already in base zone: $a.');
      }
    }
    _leaders.add(leader);
  }

  /// Removes a [leader] from the player's base zone.
  ///
  /// This method typically would be called when a leader unit is deployed
  /// to the ground arena.
  ///
  /// Throws if the leader is not in the base zone.
  void removeLeader(Leader leader) {
    if (!_leaders.remove(leader)) {
      throw ArgumentError(
        'Leader not in base zone: ${leader.origin.toReference(foil: false)}.',
      );
    }
  }
}

/// A zone shared by players that contains in-play [ArenaCard]s.
sealed class SharedZone extends Zone {
  SharedZone({
    required this.arena,
    Iterable<Unit> units = const [],
  }) : _units = List.of(units);

  @override
  bool get inPlay => true;

  /// The units in this shared zone.
  ///
  /// This list can only be modified by [addUnit] and [removeUnit].
  late final units = List<Unit>.unmodifiable(_units);
  final List<Unit> _units;

  /// What arena this shared zone represents.
  final Arena arena;

  /// Returns all units controlled by the given [player].
  ///
  /// Note that this does not include units owned by the player but controlled
  /// by another player, and if the control of a unit changes, it will be
  /// reflected in a _subsequent_ iteration.
  Iterable<Unit> unitsControlledBy(Player player) {
    return units.where((unit) => unit.controlledBy == player);
  }

  /// Adds a [unit] to the shared zone.
  ///
  /// This method typically would be called when a unit is deployed.
  ///
  /// Throws if the unit's [ArenaCard.arena] does not match [arena].
  void addUnit(Unit unit) {
    if (unit.origin.card.arena != arena) {
      throw ArgumentError.value(
        unit,
        'unit',
        ''
            'Unit arena (${unit.origin.card.arena.name}) does not match shared '
            'zone arena (${arena.name}).',
      );
    }
    _units.add(unit);
  }

  /// Removes a [unit] from the shared zone.
  ///
  /// Throws if the unit is not in the shared zone.
  void removeUnit(Unit unit) {
    if (!_units.remove(unit)) {
      throw ArgumentError.value(
        unit,
        'unit',
        'Unit not in shared zone.',
      );
    }
  }
}

/// A shared zone representing the ground arena.
final class GroundArena extends SharedZone {
  /// Creates a new ground arena with the given [units].
  GroundArena({
    super.units,
  }) : super(arena: Arena.ground);
}

/// A shared zone representing the space arena.
final class SpaceArena extends SharedZone {
  /// Creates a new space arena with the given [units].
  SpaceArena({
    super.units,
  }) : super(arena: Arena.space);
}

/// A player's resource zone, where they store resources.
final class ResourceZone extends Zone {
  /// Creates a new resource zone with the given [resources].
  ResourceZone({
    Iterable<StyledCard<DeckCard>> resources = const [],
  }) : _resources = List.of(resources);

  @override
  bool get inPlay => true;

  /// The resources in this zone.
  ///
  /// This list can only be modified by [addResource] and [removeResource].
  late final resources = List<StyledCard<DeckCard>>.unmodifiable(_resources);
  final List<StyledCard<DeckCard>> _resources;

  /// Adds a [resource] to the resource zone.
  void addResource(StyledCard<DeckCard> resource) {
    _resources.add(resource);
  }

  /// Removes a [resource] from the resource zone.
  ///
  /// Throws if the resource is not in the resource zone.
  void removeResource(StyledCard<DeckCard> resource) {
    if (!_resources.remove(resource)) {
      throw ArgumentError.value(
        resource,
        'resource',
        'Resource not in resource zone.',
      );
    }
  }
}

/// A player's deck zone, where they store their deck.
final class DeckZone extends Zone {
  /// Creates a new deck zone with the given [cards].
  DeckZone({
    Iterable<StyledCard<DeckCard>> cards = const [],
  }) : _cards = List.of(cards);

  @override
  bool get inPlay => false;

  /// The cards in this zone.
  ///
  /// This list can only be modified by the other methods in this class.
  late final cards = List<StyledCard<DeckCard>>.unmodifiable(_cards);
  final List<StyledCard<DeckCard>> _cards;

  /// Returns the top [count] cards from the deck without removing them.
  ///
  /// If there are fewer than [count] cards in the deck, returns all of them.
  ///
  /// Throws if [count] is not at least 1.
  Iterable<StyledCard<DeckCard>> peek(int count) {
    if (count < 1) {
      throw RangeError.value(count, 'count', 'Must be at least 1.');
    }
    return cards.take(count);
  }

  /// Removes the top [count] cards from the deck and returns them.
  ///
  /// If there are fewer than [count] cards in the deck, returns all of them.
  ///
  /// Throws if [count] is not at least 1.
  List<StyledCard<DeckCard>> draw(int count) {
    if (count < 1) {
      throw RangeError.value(count, 'count', 'Must be at least 1.');
    }
    final drawn = cards.sublist(0, count);
    _cards.removeRange(0, drawn.length);
    return drawn;
  }

  /// Shuffles the deck.
  ///
  /// If [random] is provided, it will be used to shuffle the deck.
  void shuffle([Random? random]) {
    _cards.shuffle(random ?? defaultRandom);
  }

  /// Inserts [cards] at the top of the deck.
  void insertTop(Iterable<StyledCard<DeckCard>> cards) {
    _cards.insertAll(0, cards);
  }

  /// Inserts [cards] at the bottom of the deck.
  void insertBottom(Iterable<StyledCard<DeckCard>> cards) {
    _cards.addAll(cards);
  }
}

/// A player's hand zone, where they store their hand of cards.
final class HandZone extends Zone {
  /// Creates a new hand zone with the given [cards].
  HandZone({
    Iterable<StyledCard<DeckCard>> cards = const [],
  }) : _cards = List.of(cards);

  @override
  bool get inPlay => false;

  /// The cards in this zone.
  ///
  /// This list can only be modified by the other methods in this class.
  late final cards = List<StyledCard<DeckCard>>.unmodifiable(_cards);
  final List<StyledCard<DeckCard>> _cards;

  /// Adds a [card] to the hand.
  void addCard(StyledCard<DeckCard> card) {
    _cards.add(card);
  }

  /// Removes a [card] from the hand.
  ///
  /// Throws if the card is not in the hand.
  void removeCard(StyledCard<DeckCard> card) {
    if (!_cards.remove(card)) {
      throw ArgumentError.value(
        card,
        'card',
        'Card not in hand.',
      );
    }
  }
}

/// A player's discard zone, where they store their discarded cards.
final class DiscardZone extends Zone {
  /// Creates a new discard zone with the given [cards].
  DiscardZone({
    Iterable<StyledCard<DeckCard>> cards = const [],
  }) : _cards = List.of(cards);

  @override
  bool get inPlay => false;

  /// The cards in this zone.
  ///
  /// This list can only be modified by the other methods in this class.
  late final cards = List<StyledCard<DeckCard>>.unmodifiable(_cards);
  final List<StyledCard<DeckCard>> _cards;

  /// Adds a [card] to the discard pile.
  void addCard(StyledCard<DeckCard> card) {
    _cards.add(card);
  }

  /// Removes a [card] from the discard pile.
  ///
  /// Throws if the card is not in the discard pile.
  void removeCard(StyledCard<DeckCard> card) {
    if (!_cards.remove(card)) {
      throw ArgumentError.value(
        card,
        'card',
        'Card not in discard pile.',
      );
    }
  }
}
