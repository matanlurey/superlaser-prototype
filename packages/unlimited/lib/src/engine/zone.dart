import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:unlimited/build.dart';
import 'package:unlimited/core.dart';

/// An opaque object representing a player in the game.
///
/// This object is used to track player-specific state and actions as a thin
/// wrapper around the provided [key], which should be unique to each player.
@immutable
final class Player {
  /// Creates a new player with the given unique [key].
  ///
  /// Exactly how this key is generated is up to the user, but it should be
  /// unique to each player in the game. In the simplest case, this could be a
  /// simple string or integer:
  ///
  /// ```dart
  /// // This is a completely valid way to create players.
  /// final players = [
  ///   Player(key: '1'),
  ///   Player(key: '2'),
  /// ];
  /// ```
  Player({
    required this.key,
  });

  /// The unique key for this player.
  final String key;

  @override
  bool operator ==(Object other) {
    if (other is Player) {
      return key == other.key;
    }
    return false;
  }

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() {
    return 'Player <#$key>';
  }
}

/// A game object backed by a [Card] of type [T].
///
/// Entities are the primary objects in the game, representing cards, units, and
/// upgrades. An entity is intended to be a thin wrapper around an [origin] card
/// providing additional state and functionality.
///
/// Every entity:
/// - has an [origin] card that it represents its base properties and artwork;
/// - has state that is visible and can be recreated by calling the constructor;
/// - can be modified by cards, abilities, or other effects.
///
/// While no support is built-in for serialization, it must be possible to
/// recreate the state of an entity by calling the constructor with the same
/// arguments.
abstract final class Entity<T extends Card> {
  Entity({
    required this.origin,
  });

  /// Which card and artwork this entity represents.
  final StyledCard<T> origin;
}

/// A game object that can receive damage and can be defeated.
///
/// The primary attributes of a target are (everything else is derived):
/// - [damage], which represents the current damage on the target;
/// - [healthModifier], which represents additional health added to the target.
///
/// The target [isDefeated] when [damage] is greater than or equal to [health].
abstract final class Target<T extends TargetCard> extends Entity<T> {
  Target({
    required super.origin,
    int damage = 0,
    int healthModifier = 0,
  })  : _damage = damage,
        _healthModifier = healthModifier {
    RangeError.checkNotNegative(damage, 'damage');
    RangeError.checkNotNegative(healthModifier, 'healthModifier');
  }

  int _damage;

  /// The current damage on this target.
  ///
  /// This value is always non-negative.
  @nonVirtual
  int get damage => _damage;

  /// Sets the damage on this target.
  ///
  /// This setter is provided for convenience, but it is recommended to use
  /// [dealDamage] and [healDamage] instead to make interactions more explicit,
  /// and in the former case, account for excess damage.
  ///
  /// The [value] must be non-negative.
  @nonVirtual
  set damage(int value) {
    RangeError.checkNotNegative(value, 'value');
    _damage = value;
  }

  int _healthModifier;

  /// Deals [damage] to this target.
  ///
  /// Returns the amount of damage that is in excess of the target's health.
  ///
  /// The [damage] must be at least 1. See [healDamage] for the inverse.
  @nonVirtual
  int dealDamage(int damage) {
    if (damage < 1) {
      throw RangeError.value(damage, 'damage', 'Must be at least 1.');
    }

    // Deal the actual damage.
    this.damage += damage;

    // Calculate how much of this damage was in excess.
    final excess = this.damage - health;

    // Only damage done as a result of this method is considered excess. For
    // example, if the target somehow had 7 damage (of 5 health) and then took
    // 1 more damage, the excess would be 1, not 3.
    return math.max(damage, excess);
  }

  /// Heals [damage] from this target.
  ///
  /// Returns the amount of damage that was healed.
  ///
  /// The [damage] must be at least 1. See [dealDamage] for the inverse.
  @nonVirtual
  int healDamage(int damage) {
    if (damage < 1) {
      throw RangeError.value(damage, 'damage', 'Must be at least 1.');
    }

    // Calculate how much damage can be healed.
    final healed = math.min(damage, this.damage);

    // Heal the actual damage.
    this.damage -= healed;

    return healed;
  }

  /// The current health modifier on this target.
  ///
  /// Health can be modified by cards, abilities, or other effects.
  ///
  /// This setter is provided for convenience, but it is recommended to use
  /// [addHealthModifier] and [resetHealthModifier] instead to make interactions
  /// more explicit.
  ///
  /// This value is always non-negative.
  @nonVirtual
  int get healthModifier => _healthModifier;

  /// Sets the health modifier on this target.
  ///
  /// The [value] must be non-negative.
  @nonVirtual
  set healthModifier(int value) {
    RangeError.checkNotNegative(value, 'value');
    _healthModifier = value;
  }

  /// Adds [value] to the health modifier on this target.
  ///
  /// The value must be at least 1.
  @nonVirtual
  void addHealthModifier(int value) {
    if (value < 1) {
      throw RangeError.value(value, 'value', 'Must be at least 1.');
    }
    healthModifier += value;
  }

  /// Resets the health modifier on this target (i.e. sets it to `0`).
  ///
  /// This is a convenience method to reset the health modifier to its default
  /// value. It is recommended to use this method instead of setting the health
  /// modifier directly to `0` to make interactions more explicit.
  ///
  /// For example, when recalculating the health modifier based on active
  /// upgrades, it is recommended to call this method, and then iterate over the
  /// active upgrades to apply their health modifiers.
  @nonVirtual
  void resetHealthModifier() {
    healthModifier = 0;
  }

  /// The total health of this target.
  ///
  /// This value is always non-negative.
  @nonVirtual
  int get health => origin.card.health + healthModifier;

  /// Whether the target is considered defeated ([damage] >= [health]).
  @nonVirtual
  bool get isDefeated => damage >= health;
}

/// Represents a player's base in the game.
final class Base extends Target<BaseCard> {
  /// Creates a new base with the given [origin] and optional starting state.
  Base({
    required super.origin,
    super.damage,
    super.healthModifier,
  });
}

// TODO: Implement.
final class Leader {
  Leader._();

  LeaderCard get card => throw UnimplementedError();

  Unit toUnit({required BaseZone origin}) => throw UnimplementedError();
}

// TODO: Implement.
final class Unit {
  Unit._();

  UnitCard get card => throw UnimplementedError();
}

// TODO: Implement.
final class LeaderUnit implements Unit {
  LeaderUnit._();

  @override
  UnitCard get card => throw UnimplementedError();
}

/// Defined areas of the game with specific rules.
///
/// This is a _marker_ type, meaning it has no properties or methods.
sealed class Zone {}

/// Each player has a base zone, which contains their base and leader(s).
final class BaseZone extends Zone {
  /// Creates a new base zone with the given [base] and [leader].
  BaseZone({
    required this.base,
    required Leader leader,
  }) : _leaders = [leader];

  /// Creates a new base zone with the given [base] and [leaders].
  BaseZone.twinSuns({
    required this.base,
    required (Leader, Leader) leaders,
  }) : _leaders = [leaders.$1, leaders.$2];

  final List<Leader> _leaders;

  /// The base card for the zone.
  final Base base;

  /// The leader card(s) in the zone.
  ///
  /// This list is unmodifiable, and has between 0 and 2 elements, depending on
  /// the deck format (i.e. [TwinSunsDeck] will have 2 leaders compared to a
  /// standard deck with 1 leader) and whether the leader(s) are in play (in
  /// [GroundArena]).
  ///
  /// To modify, use [deploy] or [GroundArena.defeat] on the [LeaderUnit].
  late final leaders = List<Leader>.unmodifiable(_leaders);

  /// The count of aspect icons from both the base and leader(s).
  ///
  /// The order of the aspects is not guaranteed.
  ///
  /// This list is unmodifiable.
  late final aspects = List<Aspect>.unmodifiable([
    ...base.card.aspects.values,
    for (final leader in _leaders) ...leader.card.aspects.values,
  ]);

  /// Deploys the leader to the given [arena].
  ///
  /// The [leader] must be currently present in this zone.
  void deploy(Leader leader, GroundArena arena) {
    if (!_leaders.remove(leader)) {
      throw ArgumentError.value(leader, 'leader', 'Not in this zone.');
    }
    arena.deploy(leader.toUnit(origin: this));
  }

  /// Returns `true` if the zone has insufficient [aspects] to play [card].
  @useResult
  bool lacksAspects(Card card) {
    final check = aspects.toList();
    for (final aspect in card.aspects.values) {
      if (!check.remove(aspect)) {
        return true;
      }
    }
    return false;
  }
}

/// A zone shared by all players.
sealed class SharedZone extends Zone {}

/// The ground arena, where [Arena.ground] units are deployed.
final class GroundArena extends SharedZone {
  void deploy(Unit unit) {}
  void defeat(Unit unit) {}
}

/// The space arena, where [Arena.space] units are deployed.
final class SpaceArena extends SharedZone {}
