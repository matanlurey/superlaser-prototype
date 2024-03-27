/// A gameplay engine for the [Star Wars: Unlimited] Trading Card Game.
///
/// [star wars: unlimited]: https://starwarsunlimited.com/
///
/// This library provides gameplay logic and data structures. It is intended to
/// be used when building anything like a simulator, a game client, or a game
/// visualizer.
///
/// Most data structures in this library are _mutable_ where they would be
/// modified during gameplay. For example, a [Base] can be damaged, so it's
/// mutable. However a [Deck] is _immutable_ because it's a collection of cards
/// that doesn't change during gameplay (you'll need to write your own logic for
/// something like deck building).
///
/// ## Usage
///
/// ```dart
/// import 'package:unlimited/engine.dart';
/// ```
///
/// ## Scope
///
/// This library provides static type checking and some low-level correctness
/// checks. For example, the [PremierDeck] class ensures that the deck has at
/// least 50 cards and no more than 3 copies of any card. However, it does not
/// try to simulate the game rules, and as such is missing concepts such as
/// "valid action", "current player", or "defeated unit", which are left to the
/// user to implement:
///
/// ```dart
/// void example(Base base) {
///   // Go ahead and place 1000 damage on the base.
///   base.damage(1000);
///   print(base.damage()); // 1000, even though in game rules the game is over.
///
///   // Ok, now heal it back to 30.
///   base.damage(-1000);
///   print(base.damage); // 30.
/// }
/// ```
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
import 'package:unlimited/src/build/deck.dart';
import 'package:unlimited/src/engine/state.dart';

export 'src/build/deck.dart';
export 'src/engine/game.dart';
export 'src/engine/id.dart';
export 'src/engine/player.dart';
export 'src/engine/state.dart';
export 'src/engine/zone.dart';
