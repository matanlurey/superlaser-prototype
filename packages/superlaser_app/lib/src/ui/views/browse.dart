import 'package:flutter/material.dart';
import 'package:unlimited/catalog.dart' as built_in show catalog;
import 'package:unlimited/core.dart';

/// Browse the card catalog.
final class Browse extends StatelessWidget {
  /// Creates a new [Browse] view.
  ///
  /// If [catalog] is not provided, the built-in catalog is used.
  Browse({
    Catalog? catalog,
    super.key,
  }) : catalog = catalog ?? built_in.catalog;

  /// Catalog of [Star Wars: Unlimited] expansions and cards.
  ///
  /// [star wars: unlimited]: https://starwarsunlimited.com
  final Catalog catalog;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse'),
      ),
      body: const Center(
        child: Placeholder(),
      ),
    );
  }
}
