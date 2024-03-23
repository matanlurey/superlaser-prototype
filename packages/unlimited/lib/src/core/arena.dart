import 'package:unlimited/src/core/card.dart';
import 'package:unlimited/src/utils.dart';

/// Possible shared zones for unit cards (i.e. sub-types of [ArenaCard]).
enum Arena {
  /// Where all ground units are placed.
  ground,

  /// Where all space units are placed.
  space;

  @override
  String toString() => 'Arena <${name.capitalize()}>';
}
