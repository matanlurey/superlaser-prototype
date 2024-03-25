import 'dart:convert';

import 'package:app/src/tools/collection.dart';
import 'package:app/src/tools/persist.dart';
import 'package:app/ui.dart';
import 'package:flutter/material.dart';
import 'package:unlimited/catalog.dart' as built_in show catalog;
import 'package:unlimited/core.dart';

/// Manage a card collection.
final class CollectView extends StatefulWidget {
  /// Creates a new [CollectView].
  ///
  /// If [catalog] is not provided, the built-in catalog is used.
  CollectView({
    required this.persistence,
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

  /// Persistence layer for saving and loading collections.
  final Persistence persistence;

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
            onPressed: () async {
              final json = _collection.toJson();
              await widget.persistence.export(
                jsonEncode(json),
                fileName: 'collection.json',
              );
            },
          ),
          // Button that opens a menu of other actions.
          PopupMenuButton<String>(
            itemBuilder: (_) {
              return [
                PopupMenuItem(
                  value: 'import',
                  child: const Text('Bulk Add CSV'),
                  onTap: () async {
                    final csv = await widget.persistence.import(
                      allowedExtensions: ['csv'],
                    );
                    if (csv != null) {
                      setState(() {
                        _collection.parseAndAddCsv(csv);
                      });
                    }
                  },
                ),
                PopupMenuItem(
                  value: 'reset',
                  child: const Text('Export to CSV'),
                  onTap: () async {
                    final csv = _collection.toCsv();
                    await widget.persistence.export(
                      csv,
                      fileName: 'collection.csv',
                    );
                  },
                ),
              ];
            },
            onSelected: (value) async {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (_) {
              return _Add(
                onAdd: (card) {
                  setState(() {
                    _collection.add(card);
                  });
                },
              );
            },
          );
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
                  onSelectChanged: (_) async {
                    // Open a bottom sheet to preview and edit the copies.
                    await showModalBottomSheet<void>(
                      context: context,
                      builder: (_) {
                        return _ViewAndEditRow(
                          card: row.card,
                          initialQuantity: row.copies,
                          onQuantityChanged: (quantity) {
                            setState(() {
                              _collection.set(row.card, quantity);
                            });
                          },
                        );
                      },
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

final class _ViewAndEditRow extends StatefulWidget {
  const _ViewAndEditRow({
    required this.card,
    required this.initialQuantity,
    required this.onQuantityChanged,
  });

  final CardReference card;
  final int initialQuantity;
  final void Function(int) onQuantityChanged;

  @override
  State<_ViewAndEditRow> createState() => _ViewAndEditRowState();
}

class _ViewAndEditRowState extends State<_ViewAndEditRow> {
  late int quantity = widget.initialQuantity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    quantity--;
                  });
                  widget.onQuantityChanged(quantity);
                  if (quantity == 0) {
                    // Dismiss the bottom sheet.
                    Navigator.of(context).pop();
                  }
                },
              ),
              const SizedBox(width: 16),
              Text('$quantity'),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    quantity++;
                  });
                  widget.onQuantityChanged(quantity);
                },
              ),
            ],
          ),
          Expanded(
            child: CardImage(
              card: widget.card,
            ),
          ),
        ],
      ),
    );
  }
}

/// Floating window that presents a text box for the user to input card numbers.
final class _Add extends StatefulWidget {
  const _Add({
    required this.onAdd,
  });

  final void Function(CardReference) onAdd;

  @override
  State<_Add> createState() => _AddState();
}

class _AddState extends State<_Add> {
  var _foil = false;

  final _controller = TextEditingController();

  void _add(int number, bool foil) {
    widget.onAdd(
      CardReference(
        expansion: 'sor',
        number: number,
        foil: foil,
      ),
    );
  }

  @override
  void initState() {
    _controller.addListener(() {
      final text = _controller.text;
      if (text.length == 3) {
        final number = int.tryParse(text);
        if (number != null) {
          _add(number, _foil);
          setState(() {
            _controller.clear();
            _foil = false;
          });
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Card number',
              hintText: 'Enter the card number (i.e. ###)',
            ),
          ),
          CheckboxListTile(
            title: const Text('Foil'),
            value: _foil,
            onChanged: (foil) {
              setState(() {
                _foil = foil ?? false;
              });
            },
          ),
        ],
      ),
    );
  }
}

extension on Collection {
  /// Parses a CSV string and adds the cards to the collection.
  ///
  /// See [toCsv] for information on the format.
  void parseAndAddCsv(String csv) {
    final lines = LineSplitter.split(csv);
    for (final line in lines.skip(1)) {
      final parts = line.split(',');
      final expansion = parts[0].toLowerCase();
      final number = int.parse(parts[1]);
      final copies = int.parse(parts[2]);
      final foil = parts[3] == 'true';
      final card = CardReference(
        expansion: expansion,
        number: number,
        foil: foil,
      );
      set(card, this.copies(card) + copies);
    }
  }

  /// Converts the collection to a CSV string.
  ///
  /// The format is the popular `swudb.com` format:
  /// ```csv
  /// Set,CardNumber,Count,IsFoil
  /// SOR,005,3,false
  /// SOR,100,4,true
  /// SOR,123,2,false
  /// SOR,123,3,true
  /// ```
  ///
  /// See https://github.com/matanlurey/superlaser/blob/main/docs/external.md.
  String toCsv() {
    final buffer = StringBuffer()..writeln('Set,CardNumber,Count,IsFoil');
    for (final row in cards) {
      buffer
        ..writeAll(
          [
            row.card.expansion.toUpperCase(),
            row.card.number.toString().padLeft(3, '0'),
            row.copies,
            row.card.foil,
          ],
          ',',
        )
        ..writeln();
    }
    return buffer.toString();
  }
}
