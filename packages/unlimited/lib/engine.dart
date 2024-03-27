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
/// ## Scope
///
/// This library provides static type checking and some low-level correctness
/// checks. For example, the [Base] class can never have _negative_ damage:
///
/// ```dart
/// void example(Base base) {
///   print(base.damage()); // 0, starting off undamaged.
///   print(base.damage(10)); // 10, taking 10 damage.
///   print(base.damage(-20)); // 0, cannot have negative damage.
/// }
/// ```
library engine;
