import 'package:flutter/material.dart';
import 'package:superlaser_app/src/tools/collection.dart';
import 'package:superlaser_app/ui.dart';
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
        child: Builder(
          builder: (context) {
            return DataTable(
              showCheckboxColumn: false,
              columnSpacing: 30,
              columns: const [
                DataColumn(label: Text('Set')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Copies'), numeric: true),
              ],
              rows: _collection.cards.map((row) {
                var name = widget.catalog.lookup(row.card)!.card.name;
                if (row.card.foil) {
                  name = '(Foil) $name';
                }
                return DataRow(
                  onSelectChanged: (_) {
                    // Open a bottom sheet to preview and edit the copies.
                    showBottomSheet(
                      context: context,
                      builder: (_) => _ViewAndEditRow(card: row.card),
                    );
                  },
                  cells: [
                    DataCell(Text(row.card.expansion.toUpperCase())),
                    DataCell(
                      Text(
                        '#${row.card.number}: $name',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DataCell(Text('${row.copies}')),
                  ],
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

final class _ViewAndEditRow extends StatelessWidget {
  const _ViewAndEditRow({
    required this.card,
  });

  final CardReference card;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CardImage(
          card: card,
        ),
      ],
    );
  }
}
