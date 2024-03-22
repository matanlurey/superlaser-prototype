import 'package:flutter/material.dart';
import 'package:superlaser_app/ui.dart';
import 'package:unlimited/catalog.dart' as built_in show catalog;
import 'package:unlimited/core.dart' as swu;

/// Browse the card catalog.
final class BrowseView extends StatelessWidget {
  /// Creates a new [BrowseView].
  ///
  /// If [catalog] is not provided, the built-in catalog is used.
  BrowseView({
    swu.Catalog? catalog,
    super.key,
  }) : catalog = catalog ?? built_in.catalog;

  /// Catalog of [Star Wars: Unlimited] expansions and cards.
  ///
  /// [star wars: unlimited]: https://starwarsunlimited.com
  final swu.Catalog catalog;

  @override
  Widget build(BuildContext context) {
    final allCards = catalog.allCards.toList();
    final resolver = CardImageProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Cards'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2,
        ),
        itemCount: allCards.length,
        itemBuilder: (context, index) {
          final card = allCards[index];
          final Color color;
          if (card.aspects.values.isNotEmpty) {
            color = Color(card.aspects.values.first.color);
          } else {
            color = Colors.grey;
          }
          return Card(
            surfaceTintColor: color,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) {
                      return Scaffold(
                        appBar: AppBar(
                          title: Text(card.name),
                        ),
                        body: Center(
                          child: Image(
                            image: resolver(
                              card.toReference(),
                              CardImageType.front,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              child: Column(
                children: [
                  Expanded(
                    child: CardImage(
                      card: card.toReference(),
                      type: CardImageType.thumb,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      '${card.unique ? '✦ ' : ''}${card.name}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
