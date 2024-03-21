/// All known (released and pre-release) cards in [Star Wars: Unlimited].
///
/// This library is provided as a convenience for developers who want to
/// reference cards, expansions, and other game data in their own projects
/// without needing to develop their own data parsing or scraping solutions.
///
/// [star wars: unlimited]: https://starwarsunlimited.com/
///
/// ## Usage
///
/// ```dart
/// import 'package:unlimited/catalog.dart';
///
/// void main() {
///   print(catalog.lookup(CardReference('sor', 1)); // SOR <001/252>
/// }
/// ```
///
/// To import specific releases, use the `catalog` directory:
///
/// ```dart
/// import 'package:unlimited/catalog/sor.dart' as sor;
///
/// void main() {
///   print(sor.cards.first); // SOR <001/252>
/// }
/// ```
library catalog;

import 'package:unlimited/catalog/sor.dart' as sor;
import 'package:unlimited/core.dart';

// TODO: Exporting core.dart causes "unresolved export uri" in dartdoc.
export 'package:unlimited/src/core/card.dart' show CardReference;

/// A collection of all known expansions and their cards.
final catalog = Catalog.from([
  sor.cards,
]);
