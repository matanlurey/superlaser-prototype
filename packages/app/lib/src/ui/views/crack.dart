import 'package:app/ui.dart';
import 'package:flutter/material.dart';
import 'package:unlimited/catalog/sor.dart' as sor;
import 'package:unlimited/core.dart' hide Card;
import 'package:unlimited/engine.dart';

/// Crack a simulated booster pack.
final class CrackView extends StatefulWidget {
  /// Creates a new [CrackView].
  const CrackView({
    super.key,
  });

  @override
  State<CrackView> createState() => _CrackViewState();
}

final class _CrackViewState extends State<CrackView> {
  static final _generator = BoosterGenerator(sor.cards);

  BoosterPack? _pack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crack a Pack'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _pack = _generator.create();
              });
            },
          ),
        ],
      ),
      body: _pack == null
          ? Center(
              child: MaterialButton(
                onPressed: () {
                  setState(() {
                    _pack = _generator.create();
                  });
                },
                // Primary color.
                textTheme: ButtonTextTheme.primary,
                child: const Text('Crack a Pack'),
              ),
            )
          : ListView(
              children: [
                for (final card in _pack!.cards)
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) {
                            return Scaffold(
                              appBar: AppBar(
                                title: Text(card.card.name),
                              ),
                              body: Center(
                                child: CardImage(
                                  card: card.toReference(),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    child: Card(
                      child: ListTile(
                        title: Text(
                          '${card.card.unique ? '✦ ' : ''}${card.card.name}',
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${card.card.rarity.name[0].capitalize()} '
                          '${card.isFoil ? 'F ' : ''}'
                          '${card is VariantCard ? '${card.type.name.capitalize()} ' : ''}',
                        ),
                        leading: CardImage(
                          card: card.toReference(),
                          type: CardImageType.thumb,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
