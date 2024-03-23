import 'package:meta/meta.dart';
import 'package:unlimited/src/engine/id.dart';

/// A player in the game.
///
/// Player is intentionally an opaque reference to a player in the game, used
/// to uniquely identify a player in the game state, but not to expose any
/// player-specific information or metadata.
@immutable
final class Player {
  /// Creates a new player with a unique identifier.
  Player() : _id = Id();

  /// Creates a new player with the given identifier.
  Player.withId(this._id);

  final Id _id;

  @override
  bool operator ==(Object other) {
    return other is Player && other._id == _id;
  }

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() => 'Player <$_id>';
}
