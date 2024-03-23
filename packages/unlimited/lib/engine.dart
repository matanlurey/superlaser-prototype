/// A gameplay engine for the [Star Wars: Unlimited] Trading Card Game.
///
/// [star wars: unlimited]: https://starwarsunlimited.com/
///
/// This library provides gameplay logic and data structures. It is intended to
/// be used when building anything like a simulator, a game client, or a game
/// visualizer.
///
/// ## Usage
///
/// ```dart
/// import 'package:unlimited/engine.dart';
/// ```
///
/// ## Validation
///
/// Where possible, this library will validate the game state and enforce the
/// rules of the game. However, it is not a complete rules engine, and it is
/// possible to create invalid game states. It is the responsibility of the
/// caller to ensure that the game state is valid.
///
/// In addition, this library does not provide any user interface or invalid
/// input handling beyond throwing errors that are not expected to be caught.
/// For example, programs that take input to build a [PremierDeck] should check
/// constraints (such as at least 50 cards, no more than 3 copies) before
/// creating the deck:
///
/// ```dart
/// import 'package:unlimited/core.dart';
/// import 'package:unlimited/engine.dart';
///
/// void example(LeaderCard leader, BaseCard base, List<DeckCard> cards) {
///   if (cards.length < 50) {
///     print('Deck must have at least 50 cards.');
///     return;
///   }
///   // ...
/// }
/// ```
library engine;

// Imported for documentation purposes.
import 'package:unlimited/src/engine/deck.dart';

export 'src/engine/deck.dart';
export 'src/engine/game.dart';
export 'src/engine/id.dart';
export 'src/engine/player.dart';
export 'src/engine/state.dart';
export 'src/engine/zone.dart';
