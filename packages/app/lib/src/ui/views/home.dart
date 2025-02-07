import 'package:app/src/tools/collection.dart';
import 'package:app/src/tools/persist.dart';
import 'package:app/ui.dart';
import 'package:flutter/material.dart';
import 'package:jsonut/jsonut.dart';
import 'package:unlimited/catalog.dart' as built_in show catalog;
import 'package:unlimited/core.dart';

/// Provides navigation to other views.
final class HomeView extends StatelessWidget {
  /// Creates a new [HomeView].
  ///
  /// If [catalog] is not provided, the built-in catalog is used.
  HomeView({
    required this.persistence,
    Catalog? catalog,
    super.key,
  }) : catalog = catalog ?? built_in.catalog;

  /// Catalog of [Star Wars: Unlimited] expansions and cards.
  ///
  /// [star wars: unlimited]: https://starwarsunlimited.com
  final Catalog catalog;

  /// Persistence layer for storing data.
  final Persistence persistence;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttons = _buildButtons(context);
    return Scaffold(
      body: Center(
        child: ListView(
          children: [
            const SizedBox(
              height: 32,
            ),
            Text(
              'Superlaser',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            Text(
              'Star Wars: Unlimited Utility Kit',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(
              height: 32,
            ),
            SizedBox(
              width: 300,
              height: 500,
              child: ListView.separated(
                itemCount: buttons.length,
                separatorBuilder: (context, index) => const SizedBox(
                  height: 8,
                ),
                itemBuilder: (context, index) => buttons[index],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildButtons(BuildContext context) {
    return [
      ListTile(
        leading: const SizedBox(
          width: 24,
          height: 24,
          child: Icon(Icons.search),
        ),
        title: const Text('Browse Cards'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => BrowseView(catalog: catalog),
            ),
          );
        },
      ),
      ListTile(
        leading: const SizedBox(
          width: 24,
          height: 24,
          child: Icon(Icons.collections),
        ),
        title: const Text('Manage Collection'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          // Ask whether to import a collection or start a new one.
          final result = await showDialog<bool>(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: const Text('Manage Collection'),
                content: const Text(
                  'Load a collection.json or start a new one?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Load'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('New'),
                  ),
                ],
              );
            },
          );

          if (result == null || !context.mounted) {
            return;
          }

          if (!result) {
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => CollectView(
                  catalog: catalog,
                  persistence: persistence,
                ),
              ),
            );
            return;
          }

          // Import a card collection.
          final import = await persistence.import(
            allowedExtensions: ['json'],
          );
          if (import == null || !context.mounted) {
            return;
          }
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => CollectView(
                catalog: catalog,
                initialCollection: Collection.fromJson(
                  JsonArray.parse(import),
                ),
                persistence: persistence,
              ),
            ),
          );
        },
      ),
      ListTile(
        leading: const SizedBox(
          width: 24,
          height: 24,
          child: Icon(Icons.folder_open),
        ),
        title: const Text('Crack a Pack'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => const CrackView(),
            ),
          );
        },
      ),
    ];
  }
}
