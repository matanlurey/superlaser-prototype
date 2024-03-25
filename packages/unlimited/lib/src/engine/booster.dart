import 'dart:math';

import 'package:collection/collection.dart';
import 'package:unlimited/core.dart';

/// A generator for creating booster packs.
///
/// This class is used to generate booster packs for a given expansion. It
/// provides a way to create a randomized booster pack approximately matching
/// the distribution of cards in physical booster packs.
///
/// See [BoosterPack.cards] for more details on the distribution.
///
/// ## Performance
///
/// The generator is designed to be efficient, but should be cached per
/// expansion to avoid unnecessary re-generation of the same booster generator
/// (which internally caches and indexes cards).
///
/// ```dart
/// final generator = BoosterGenerator(expansion);
///
/// // Reuse the generator to create multiple booster packs.
/// for (var i = 0; i < 10; i++) {
///   final booster = generator.create();
///   print(booster);
/// }
/// ```
final class BoosterGenerator {
  /// Create a booster pack generator for the given [expansion].
  ///
  /// If [random] is not provided, a default [Random] instance is used.
  factory BoosterGenerator(CatalogExpansion expansion, {Random? random}) {
    return BoosterGenerator._(expansion, random ?? _defaultRandom);
  }

  BoosterGenerator._(this._expansion, this._random) {
    final (
      allLeaders,
      leadersByRarity,
    ) = _indexCards<LeaderCard>(_expansion.data);
    _allLeaders = allLeaders;
    _leadersByRarity = leadersByRarity;

    final (
      allBases,
      basesByRarity,
    ) = _indexCards<BaseCard>(_expansion.data);
    _allBases = allBases;
    _basesByRarity = basesByRarity;
  }

  static (List<CardOrVariant<T>>, Map<Rarity, List<CardOrVariant<T>>>)
      _indexCards<T extends Card>(
    Iterable<CardOrVariant> cards,
  ) {
    final all = cards.whereType<CardOrVariant<T>>().toList();
    return (
      all,
      groupBy<CardOrVariant<T>, Rarity>(
        all,
        (card) => card.card.rarity,
      ),
    );
  }

  static final _defaultRandom = Random();

  final CatalogExpansion _expansion;
  final Random _random;

  /// Which expansion the generator is for.
  Expansion get expansion => _expansion.expansion;

  late final List<CardOrVariant<LeaderCard>> _allLeaders;
  late final Map<Rarity, List<CardOrVariant<LeaderCard>>> _leadersByRarity;

  late final List<CardOrVariant<BaseCard>> _allBases;
  late final Map<Rarity, List<CardOrVariant<BaseCard>>> _basesByRarity;

  CardOrVariant<LeaderCard> _pullLeader([
    Rarity? rarity,
    VariantType? variant,
  ]) {
    // Do we need to filter by rarity?
    var leaders = rarity == null
        ? _allLeaders
        : _leadersByRarity[rarity] ??
            (throw StateError('No $rarity leaders in $expansion.'));

    // Do we need to filter by variant?
    if (variant != null) {
      leaders = leaders.where((leader) {
        return leader is VariantCard<LeaderCard> && leader.type == variant;
      }).toList();
    }

    // If we have no leaders left, we have a problem.
    if (leaders.isEmpty) {
      throw StateError('No leaders left in $expansion.');
    }

    // Pick a random leader.
    return leaders[_random.nextInt(leaders.length)];
  }

  /// Weighted pull for [LeaderCard].
  ///
  /// Type                              | Pull Ratio  | Pull Chance
  /// --------------------------------- | ----------- | ------------
  /// Common                            | Else        | 67.22%
  /// Rare                              | 1:6.1       | 16.40%
  /// Hyperspace Variant (Common)       | 1:7.7       | 13.00%
  /// Hyperspace Variant (Rare)         | 1:33.7      | 03.00%
  /// Showcase Variant (Either)         | 1:263.3     | 00.38%
  late final _leaderWeights = _WeightedPull<LeaderCard>(
    () => _pullLeader(Rarity.common),
    [
      (
        1.0 / 6.1,
        () => _pullLeader(Rarity.rare),
      ),
      (
        1.0 / 7.7,
        () => _pullLeader(Rarity.common, VariantType.hyperspace),
      ),
      (
        1.0 / 33.7,
        () => _pullLeader(Rarity.rare, VariantType.hyperspace),
      ),
      (
        1.0 / 263.3,
        () => _pullLeader(null, VariantType.showcase),
      ),
    ],
  );

  /// Creates and returns a new 16-card booster pack.
  ///
  /// Each booster pack contains exactly 16 cards:
  /// - 1 is guaranteed to be a [LeaderCard].
  /// - 1 is guaranteed to be a [BaseCard].
  /// - the remaining 14 are [DeckCard]s.
  ///
  /// Outside of cards exclusive to starter decks[^1], the cards are divided by
  /// [Rarity]. See [BoosterPack.cards] for more details.
  ///
  /// [^1]: i.e. [Rarity.special].
  BoosterPack create() {
    // 1. Leader card.
    final leader = _leaderWeights.pull(_random.nextDouble());

    throw UnimplementedError('TODO: Finish');
  }
}

typedef _Pull<T extends Card> = CardOrVariant<T> Function();

final class _WeightedPull<T extends Card> {
  factory _WeightedPull(
    _Pull<T> defaultCase,
    Iterable<(double, _Pull<T>)> cases,
  ) {
    final total = cases.fold<double>(
      0,
      (total, pair) => total + pair.$1,
    );
    if (total > 1.0) {
      throw ArgumentError.value(
        cases,
        'cases',
        'Total weight must be less than or equal to 1.0',
      );
    }
    return _WeightedPull<T>._withCases([
      (1.0 - total, defaultCase),
      ...cases,
    ]);
  }

  _WeightedPull._withCases(this._cases);

  final List<(double, _Pull<T>)> _cases;

  CardOrVariant<T> pull(double random) {
    var total = 0.0;
    for (final (weight, pull) in _cases) {
      total += weight;
      if (random < total) {
        return pull();
      }
    }
    throw StateError('Unreachable');
  }
}

/// A 16-card booster pack.
///
/// Each booster pack contains exactly 16 cards:
/// - 1 is guaranteed to be a [LeaderCard].
/// - 1 is guaranteed to be a [BaseCard].
/// - the remaining 14 are [DeckCard]s.
///
/// Outside of cards exclusive to starter decks[^1], the cards are divided by
/// [Rarity]. See [cards] for more details.
///
/// [^1]: i.e. [Rarity.special].
final class BoosterPack {
  /// Create a booster pack with the given [cards].
  ///
  /// This constructor is intended to be used to create a booster pack with
  /// specific cards for testing or simulation purposes. To create a _typical_
  /// (i.e. random) booster pack, use [BoosterGenerator] instead.
  factory BoosterPack.withCards({
    required CardOrVariant<LeaderCard> leader,
    required CardOrVariant<BaseCard> base,
    required Iterable<CardOrVariant> commons,
    required Iterable<CardOrVariant> uncommons,
    required CardOrVariant rareOrLegendary,
    required CardOrVariant foil,
  }) {
    return BoosterPack._([
      leader,
      base,
      ...commons,
      ...uncommons,
      rareOrLegendary,
      foil,
    ]);
  }

  BoosterPack._(Iterable<CardOrVariant> cards)
      : cards = List.unmodifiable(cards) {
    // We must always have 16 cards, and they must be from the same expansion.
    if (this.cards.length != 16) {
      throw ArgumentError.value(
        cards,
        'cards',
        'Must have exactly 16 cards',
      );
    }
    if (!this.cards.every((card) => card.card.expansion == expansion)) {
      throw ArgumentError.value(
        cards,
        'cards',
        'All cards must belong to the same set',
      );
    }
  }

  /// The cards in the booster pack in a fixed order.
  ///
  /// The order is always:
  /// - 1 [LeaderCard];
  /// - 1 [BaseCard];
  /// - 9 [Rarity.common] cards, none are duplicates;
  /// - 3 [Rarity.uncommon] cards[^1], none are duplicates;
  /// - 1 [Rarity.rare] or [Rarity.legendary] card;
  /// - 1 [CardReference.foil] card.
  ///
  /// There are no duplicates among the particular rarities, though it is
  /// possible for a card to be a variant (or foil) of another card in the pack.
  ///
  /// _**NOTE**: FFG has not published exact odds, so the distribution is based
  /// on a combination of published odds and community data. It's still random
  /// but may not match the exact distribution in physical packs._
  ///
  /// The list is unmodifiable.
  ///
  /// [^1]: One [Rarity.uncommon] card has a 6.66% chance to be upgraded to a
  ///       [VariantType.hyperspace] [Rarity.rare] or [Rarity.legendary] card.
  final List<CardOrVariant> cards;

  /// The expansion that the booster pack is from.
  Expansion get expansion => cards.first.card.expansion;
}
