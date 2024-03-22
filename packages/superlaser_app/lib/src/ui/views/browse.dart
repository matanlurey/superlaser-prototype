import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Cards'),
      ),
      body: ListView.builder(
        itemCount: allCards.length,
        itemBuilder: (context, index) {
          final card = allCards[index];
          return _CardTile(
            card: card,
            onTap: () async {
              showBottomSheet(
                context: context,
                builder: (context) {
                  return const Placeholder();
                },
              );
            },
          );
        },
      ),
    );
  }
}

final class _CardTile extends StatelessWidget {
  const _CardTile({
    required this.card,
    this.onTap,
  });

  final swu.Card card;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final neutral = card.aspects.values.firstWhereOrNull((a) => a.isNeutral);
    final morale = card.aspects.values.firstWhereOrNull((a) => a.isMorale);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: neutral != null ? Color(neutral.color) : Colors.grey,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            switch (card) {
              final swu.DeckCard c => c.cost.toString(),
              final swu.BaseCard c => c.health.toString(),
              final swu.LeaderCard c => c.unit.cost.toString(),
              _ => throw StateError('Unexpected card type: $card'),
            },
          ),
        ),
      ),
      onTap: onTap,
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      title: Text('${card.unique ? '✦ ' : ''}${card.name}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (morale == swu.Aspect.heroism)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: SizedBox(
                    width: 12,
                    height: 12,
                    child: _FactionIcon.empire,
                  ),
                )
              else if (morale == swu.Aspect.villainy)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: SizedBox(
                    width: 12,
                    height: 12,
                    child: _FactionIcon.rebels,
                  ),
                ),
              Text('${card.rarity.name.capitalize()} ${switch (card) {
                final swu.BaseCard _ => 'Base',
                final swu.LeaderCard _ => 'Leader',
                final swu.UnitCard _ => 'Unit',
                final swu.UpgradeCard _ => 'Upgrade',
                final swu.EventCard _ => 'Event',
                _ => throw StateError('Unexpected card type: $card'),
              }}'),
            ],
          ),
          Text(
            '${card.expansion.code.toUpperCase()} ${card.number.toString().padLeft(3, '0')}',
          ),
        ],
      ),
      isThreeLine: true,
    );
  }
}

final class _FactionIcon extends StatelessWidget {
  const _FactionIcon._(this._image);

  /// The Rebel Alliance faction icon.
  static final rebels = _FactionIcon._(
    SvgPicture.asset(
      'assets/rebels.svg',
      colorFilter: ColorFilter.mode(
        Color(swu.Aspect.heroism.color),
        BlendMode.srcIn,
      ),
    ),
  );

  /// The Galactic Empire faction icon.
  static final empire = _FactionIcon._(
    SvgPicture.asset(
      'assets/empire.svg',
      colorFilter: ColorFilter.mode(
        Color(swu.Aspect.heroism.color),
        BlendMode.srcIn,
      ),
    ),
  );

  final Widget _image;

  @override
  Widget build(BuildContext context) {
    return _image;
  }
}
