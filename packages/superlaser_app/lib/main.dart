import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jsonut/jsonut.dart';
import 'package:superlaser_app/src/tools/collection.dart';
import 'package:superlaser_app/src/tools/persist.dart';
import 'package:superlaser_app/ui.dart';
// import 'package:unlimited/catalog.dart';
import 'package:unlimited/core.dart';

void main() async {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      // TODO: Make this configurable/come from system settings.
      theme: ThemeData.dark(),
      home: Home(),
    ),
  );
  // runApp(
  //   _MainApp(
  //     initialCollection: Collection(),
  //     database: catalog,
  //     persistence: Persistence(),
  //   ),
  // );
}

final class _MainApp extends StatefulWidget {
  const _MainApp({
    required this.initialCollection,
    required this.database,
    required this.persistence,
  });

  final Collection initialCollection;
  final Catalog database;
  final Persistence persistence;

  @override
  State<_MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<_MainApp> {
  late Collection _collection;

  @override
  void initState() {
    super.initState();
    _collection = Collection.from(widget.initialCollection);
  }

  /// Adds the card in comparison order/increments if it already exists.
  Future<void> _add(CardReference card) async {
    setState(() {
      _collection.add(card);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cards = _collection.cards.toList();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Superlaser'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    // Show a floating bottom sheet to add a card.
                    await showModalBottomSheet<void>(
                      context: context,
                      builder: (context) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _Add(onAdd: _add),
                            ],
                          ),
                        );
                      },
                      isScrollControlled: true,
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () async {
                    // Prompt the user to confirm the action.
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Clear collection'),
                          content: const Text(
                            'Are you sure you want to clear all cards?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Clear'),
                            ),
                          ],
                        );
                      },
                    );
                    if (confirmed ?? false) {
                      setState(_collection.clear);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.file_download,
                    semanticLabel: 'Export',
                  ),
                  onPressed: () async {
                    final json = jsonEncode(_collection.toJson());
                    final result = await widget.persistence.export(
                      json,
                      fileName: 'collection.json',
                    );
                    if (mounted) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Collection exported: $result'),
                        ),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.file_upload,
                    semanticLabel: 'Import',
                  ),
                  onPressed: () async {
                    final json = await widget.persistence.import(
                      allowedExtensions: ['json'],
                    );
                    if (json == null) {
                      return;
                    }

                    setState(() {
                      _collection = Collection.fromJson(JsonArray.parse(json));
                    });

                    if (mounted) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Collection imported'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            body: ListView.builder(
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final data = cards[index];
                final name = widget.database.lookup(data.card)!.card.name;
                return ListTile(
                  title: Text(
                    '${data.card.expansion.toUpperCase()} ${data.card.number.toString().padLeft(3, '0')}',
                  ),
                  subtitle: Text('$name x${data.copies}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        _collection.remove(data.card);
                      });
                    },
                  ),
                );
              },
            ),
          );
        },
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
