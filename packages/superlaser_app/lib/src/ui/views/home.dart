import 'package:flutter/material.dart';
import 'package:superlaser_app/ui.dart';
import 'package:unlimited/catalog.dart' as built_in show catalog;
import 'package:unlimited/core.dart';

/// Provides navigation to other views.
final class HomeView extends StatelessWidget {
  /// Creates a new [HomeView].
  ///
  /// If [catalog] is not provided, the built-in catalog is used.
  HomeView({
    Catalog? catalog,
    super.key,
  }) : catalog = catalog ?? built_in.catalog;

  /// Catalog of [Star Wars: Unlimited] expansions and cards.
  ///
  /// [star wars: unlimited]: https://starwarsunlimited.com
  final Catalog catalog;

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
          // TODO: Re-add as a navigation action.
        },
        enabled: false,
      ),
    ];
  }
}
