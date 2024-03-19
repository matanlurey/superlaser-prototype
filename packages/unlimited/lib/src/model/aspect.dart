import 'package:unlimited/src/model/card.dart';
import 'package:unlimited/src/utils.dart';

/// Colored icons on a card representing different philosophies or motivations.
///
/// A deck's [LeaderCard] and [BaseCard] provide their aspect icons to that
/// deck. Although a player can include units, events, and upgrade of any aspect
/// in their deck, if they play a card with aspect icons beyond those provided
/// by the deck's leader and/or base, they will incur the aspect penalty.
///
/// There are 4 [neutral] aspects and 2 [morale] aspects.
enum Aspect {
  /// Vigilance (blue) is an aspect with a focus on defense and control.
  vigilance._neutral(0xFF4073D4),

  /// Command (green) is an aspect with a focus on powerful late-game cards.
  command._neutral(0xFF0B992D),

  /// Aggression (red) is an aspect focused on damage.
  aggression._neutral(0xFFD30808),

  /// Cunning (yellow) is an aspect focused on combat tricks and disruption.
  cunning._neutral(0xFFEB9F1C),

  /// Heroism (white) is an aspect representing morally _good_ cards.
  heroism._morale(0xFFFFFFFF),

  /// Villainy (black) is an aspect representing morally _evil_ cards.
  villainy._morale(0xFF000000);

  const Aspect._neutral(this.color) : isNeutral = true;

  const Aspect._morale(this.color) : isNeutral = false;

  /// All aspects where [isNeutral] is `true`.
  static const neutral = [
    vigilance,
    command,
    aggression,
    cunning,
  ];

  /// All aspects where [isMorale] is `true`.
  static const morale = [
    heroism,
    villainy,
  ];

  /// A 32-bit color value in ARGB format representing the aspect icon's color.
  ///
  /// The alpha channel is always 0xFF.
  ///
  /// This field is a convenience instead of every UI needing to define colors.
  final int color;

  /// Whether this aspect is considered _neutral_, or not morally good or evil.
  final bool isNeutral;

  /// Whether this aspect is considered _morale_, or not [isNeutral].
  bool get isMorale => !isNeutral;

  @override
  String toString() => 'Aspect <${name.capitalize()}>';
}
