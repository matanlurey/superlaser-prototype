import 'package:unlimited/src/model/card.dart';
import 'package:unlimited/src/utils.dart';

/// Which arena an [ArenaCard] is played in.
enum Arena {
  /// The ground arena.
  ground,

  /// The space arena.
  space;

  @override
  String toString() => 'Arena <${name.capitalize()}>';
}
