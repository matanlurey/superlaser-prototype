import 'package:flutter/material.dart';
import 'package:superlaser_app/src/tools/collection.dart';
import 'package:unlimited/catalog.dart' as built_in show catalog;
import 'package:unlimited/core.dart';

/// Manage a card collection.
final class CollectView extends StatefulWidget {
  /// Creates a new [CollectView].
  ///
  /// If [catalog] is not provided, the built-in catalog is used.
  CollectView({
    Catalog? catalog,
    Collection? initialCollection,
    super.key,
  })  : catalog = catalog ?? built_in.catalog,
        initialCollection = initialCollection ?? Collection();

  /// Catalog of [Star Wars: Unlimited] expansions and cards.
  ///
  /// [star wars: unlimited]: https://starwarsunlimited.com
  final Catalog catalog;

  /// Initial collection to manage.
  ///
  /// If not provided, an empty collection is used.
  final Collection initialCollection;

  @override
  State<CollectView> createState() => _CollectViewState();
}

class _CollectViewState extends State<CollectView> {
  late final _collection = widget.initialCollection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Collection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement adding a card to the collection.
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Table(
          columnWidths: const {
            0: IntrinsicColumnWidth(),
            1: IntrinsicColumnWidth(),
            2: FlexColumnWidth(),
            3: IntrinsicColumnWidth(),
            4: FixedColumnWidth(64),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: Colors.grey[850],
              ),
              children: const [
                Text('Expansion'),
                SizedBox(width: 8),
                Text('Card'),
                SizedBox(width: 8),
                Text(
                  'Quantity',
                  textAlign: TextAlign.right,
                ),
              ],
            ),
            ..._collection.cards.map((row) {
              var name = widget.catalog.lookup(row.card)?.card.name;
              if (row.card.foil) {
                name = '(Foil) $name';
              }
              return TableRow(
                children: [
                  Text(row.card.expansion.toUpperCase()),
                  const SizedBox(width: 8),
                  Text(
                    '${row.card.number.toString().padLeft(3, '0')}: $name',
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    row.copies.toString(),
                    textAlign: TextAlign.right,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
