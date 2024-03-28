import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:unlimited/core.dart';
import 'package:unlimited/src/core/variant.dart';

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

/// A base, which when defeated, causes the player to lose the game.
final class Base extends Target<BaseCard> {
  /// Creates a new base with the given [origin] and optional starting state.
  Base({
    required super.origin,
    super.damage,
    super.healthModifier,
  });
}

/// A unit, which can be deployed to the ground or space arena.
final class Unit extends Target<ArenaCard> {
  /// Creates a new unit with the given [origin] and optional starting state.
  Unit({
    required super.origin,
    required this.owner,
    super.damage,
    super.healthModifier,
    int powerModifier = 0,
  })  : _powerModifier = powerModifier,
        controlledBy = owner {
    RangeError.checkNotNegative(powerModifier, 'powerModifier');
  }

  /// Which player owns this unit.
  final Player owner;

  /// Which player controls this unit.
  ///
  /// This can be different from [owner] if the unit is controlled by another
  /// player, such as through a card effect.
  Player controlledBy;

  int _powerModifier;

  /// The current power modifier on this unit.
  ///
  /// Power can be modified by cards, abilities, or other effects.
  ///
  /// This value is always non-negative.
  @nonVirtual
  int get powerModifier => _powerModifier;

  /// Sets the power modifier on this unit.
  ///
  /// The [value] must be non-negative.
  ///
  /// This setter is provided for convenience, but it is recommended to use
  /// [addPowerModifier] and [resetPowerModifier] instead to make interactions
  /// more explicit.
  @nonVirtual
  set powerModifier(int value) {
    RangeError.checkNotNegative(value, 'value');
    _powerModifier = value;
  }

  /// Adds [value] to the power modifier on this unit.
  ///
  /// The value must be at least 1.
  @nonVirtual
  void addPowerModifier(int value) {
    if (value < 1) {
      throw RangeError.value(value, 'value', 'Must be at least 1.');
    }
    powerModifier += value;
  }

  /// Resets the power modifier on this unit (i.e. sets it to `0`).
  ///
  /// This is a convenience method to reset the power modifier to its default
  /// value. It is recommended to use this method instead of setting the power
  /// modifier directly to `0` to make interactions more explicit.
  ///
  /// For example, when recalculating the power modifier based on active
  /// upgrades, it is recommended to call this method, and then iterate over the
  /// active upgrades to apply their power modifiers.
  @nonVirtual
  void resetPowerModifier() {
    powerModifier = 0;
  }

  /// The total power of this unit.
  ///
  /// This value is always non-negative.
  @nonVirtual
  int get power => origin.card.power + powerModifier;
}

/// A leader, which once per game can be deployed to the ground arena.
final class Leader extends Entity<LeaderCard> {
  /// Creates a new leader with the given [origin] and optional starting state.
  Leader({
    required super.origin,
  });

  /// Returns a unit representing this leader to be deployed.
  @nonVirtual
  Unit toUnit({required Player owner}) {
    return Unit(
      origin: origin.toUnit(),
      owner: owner,
    );
  }
}
