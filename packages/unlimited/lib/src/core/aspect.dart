import 'package:meta/meta.dart';
import 'package:unlimited/src/core/card.dart';
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

  /// All aspects where [isMoral] is `true`.
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
  bool get isMoral => !isNeutral;

  @override
  String toString() => 'Aspect <${name.capitalize()}>';
}

/// Refers to 0-2 [Aspect] icons on a card.
///
/// ## Equality
///
/// Two [Aspects] are considered equal if they have the aspect icons.
@immutable
final class Aspects {
  /// One aspect icon.
  Aspects.one(Aspect this._a) : _b = null;

  /// Two aspect icons.
  Aspects.two(Aspect this._a, Aspect this._b);

  Aspects._none()
      : _a = null,
        _b = null;

  /// Create an [Aspects] instance from a list of [Aspect]s.
  ///
  /// Must have between 0 and 2 elements.
  factory Aspects.from(Iterable<Aspect> aspects) {
    final list = aspects.toList();
    if (list.isEmpty) {
      return Aspects._none();
    } else if (list.length == 1) {
      return Aspects.one(list[0]);
    } else if (list.length == 2) {
      return Aspects.two(list[0], list[1]);
    } else {
      throw RangeError.range(aspects.length, 0, 2, 'aspects');
    }
  }

  /// No aspects, a neutral card.
  static final none = Aspects._none();

  final Aspect? _a;
  final Aspect? _b;

  /// The aspect icons on the card.
  ///
  /// If there are no aspects, this list is empty.
  ///
  /// This list is unmodifiable.
  late final List<Aspect> values = List.unmodifiable(
    [
      if (_a != null) _a,
      if (_b != null) _b,
    ],
  );

  /// Returns the moral aspect, if any.
  Aspect? get moral => _a?.isMoral ?? false
      ? _a
      : _b?.isMoral ?? false
          ? _b
          : null;

  @override
  bool operator ==(Object other) {
    if (other is Aspects) {
      return _a == other._a && _b == other._b;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(_a, _b);

  @override
  String toString() {
    if (_a == null) {
      return 'Aspects <none>';
    } else if (_b == null) {
      return 'Aspects <${_a.name.capitalize()}>';
    } else {
      return 'Aspects <${_a.name.capitalize()}, ${_b.name.capitalize()}>';
    }
  }
}
