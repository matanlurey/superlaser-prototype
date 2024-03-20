import 'package:meta/meta.dart';
import 'package:unlimited/src/model/aspect.dart';

/// Flavorful attributes that categorize the card and no inherent rules.
///
/// Traits are sometimes referenced by card abilities. Common traits include:
/// - Belonging to an organization, such as [rebel] or [sith].
/// - Prominent specifes such as [twilek] or [droid].
/// - Famous professions such as [bountyHunter] or [inquisitor].
///
/// The instance hierarchy is not sealed (i.e. this class is not a true `enum`)
/// to allow for new traits to be added without breaking existing code (in
/// contrast to, for example, [Aspect]).
///
/// ## Equality
///
/// Two traits are considered equal if their [name] is equal.
@immutable
final class Trait {
  /// Creates a new trait with the given [name].
  Trait(this.name);

  /// All known traits, sorted by name in ascending order.
  static final values = List<Trait>.unmodifiable([
    bountyHunter,
    capitalShip,
    clone,
    condition,
    creature,
    disaster,
    droid,
    fighter,
    force,
    fringe,
    gambit,
    hutt,
    imperial,
    innate,
    inquisitor,
    item,
    jawa,
    jedi,
    law,
    learned,
    lightsaber,
    mandalorian,
    modification,
    newRepublic,
    official,
    plan,
    rebel,
    republic,
    resistance,
    separatist,
    sith,
    spectre,
    speeder,
    supply,
    tactic,
    tank,
    transport,
    trick,
    trooper,
    twilek,
    underworld,
    vehicle,
    walker,
    weapon,
    wookiee,
  ]);

  /// Represents the trait `Bounty Hunter`.
  static final bountyHunter = Trait('Bounty Hunter');

  /// Represents the trait `Capital Ship`.
  static final capitalShip = Trait('Capital Ship');

  /// Represents the trait `Clone`.
  static final clone = Trait('Clone');

  /// Represents the trait `Condition`.
  static final condition = Trait('Condition');

  /// Represents the trait `Creature`.
  static final creature = Trait('Creature');

  /// Represents the trait `Disaster`.
  static final disaster = Trait('Disaster');

  /// Represents the trait `Droid`.
  static final droid = Trait('Droid');

  /// Represents the trait `Fighter`.
  static final fighter = Trait('Fighter');

  /// Represents the trait `Force`.
  static final force = Trait('Force');

  /// Represents the trait `Fringe`.
  static final fringe = Trait('Fringe');

  /// Represents the trait `Gambit`.
  static final gambit = Trait('Gambit');

  /// Represents the trait `Hutt`.
  static final hutt = Trait('Hutt');

  /// Represents the trait `Imperial`.
  static final imperial = Trait('Imperial');

  /// Represents the trait `Innate`.
  static final innate = Trait('Innate');

  /// Represents the trait `Inquisitor`.
  static final inquisitor = Trait('Inquisitor');

  /// Represents the trait `Item`.
  static final item = Trait('Item');

  /// Represents the trait `Jawa`.
  static final jawa = Trait('Jawa');

  /// Represents the trait `Jedi`.
  static final jedi = Trait('Jedi');

  /// Represents the trait `Law`.
  static final law = Trait('Law');

  /// Represents the trait `Learned`.
  static final learned = Trait('Learned');

  /// Represents the trait `Lightsaber`.
  static final lightsaber = Trait('Lightsaber');

  /// Represents the trait `Mandalorian`.
  static final mandalorian = Trait('Mandalorian');

  /// Represents the trait `Modification`.
  static final modification = Trait('Modification');

  /// Represents the trait `New Republic`.
  static final newRepublic = Trait('New Republic');

  /// Represents the trait `Official`.
  static final official = Trait('Official');

  /// Represents the trait `Plan`.
  static final plan = Trait('Plan');

  /// Represents the trait `Rebel`.
  static final rebel = Trait('Rebel');

  /// Represents the trait `Republic`.
  static final republic = Trait('Republic');

  /// Represents the trait `Resistance`.
  static final resistance = Trait('Resistance');

  /// Represents the trait `Separatist`.
  static final separatist = Trait('Separatist');

  /// Represents the trait `Sith`.
  static final sith = Trait('Sith');

  /// Represents the trait `Spectre`.
  static final spectre = Trait('Spectre');

  /// Represents the trait `Speeder`.
  static final speeder = Trait('Speeder');

  /// Represents the trait `Supply`.
  static final supply = Trait('Supply');

  /// Represents the trait `Tactic`.
  static final tactic = Trait('Tactic');

  /// Represents the trait `Tank`.
  static final tank = Trait('Tank');

  /// Represents the trait `Transport`.
  static final transport = Trait('Transport');

  /// Represents the trait `Trick`.
  static final trick = Trait('Trick');

  /// Represents the trait `Trooper`.
  static final trooper = Trait('Trooper');

  /// Represents the trait `Twi'lek`.
  static final twilek = Trait("Twi'lek");

  /// Represents the trait `Underworld`.
  static final underworld = Trait('Underworld');

  /// Represents the trait `Vehicle`.
  static final vehicle = Trait('Vehicle');

  /// Represents the trait `Walker`.
  static final walker = Trait('Walker');

  /// Represents the trait `Weapon`.
  static final weapon = Trait('Weapon');

  /// Represents the trait `Wookiee`.
  static final wookiee = Trait('Wookiee');

  /// Name of the trait.
  ///
  /// Must be non-empty.
  final String name;

  @override
  bool operator ==(Object other) => other is Trait && other.name == name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'Trait <$name>';
}
