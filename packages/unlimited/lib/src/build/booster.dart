import 'dart:math';

import 'package:collection/collection.dart';
import 'package:unlimited/core.dart';
import 'package:unlimited/src/core/card.dart';
import 'package:unlimited/src/internal.dart';

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
    required StyledCard<LeaderCard> leader,
    required StyledCard<BaseCard> base,
    required Iterable<StyledCard> commons,
    required Iterable<StyledCard> uncommons,
    required StyledCard rareOrLegendary,
    required StyledCard foil,
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

  BoosterPack._(Iterable<StyledCard> cards) : cards = List.unmodifiable(cards) {
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
  final List<StyledCard> cards;

  /// Leader card in the booster pack.
  LeaderCard get leader => cards[0].card as LeaderCard;

  /// Base card in the booster pack.
  BaseCard get base => cards[1].card as BaseCard;

  /// Other cards in the booster pack (excluding [leader] and [base]).
  Iterable<StyledCard<DeckCard>> get others {
    return cards.skip(2).map((card) => card as StyledCard<DeckCard>);
  }

  /// The expansion that the booster pack is from.
  Expansion get expansion => cards.first.card.expansion;
}

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
  factory BoosterGenerator.of(CatalogExpansion expansion, {Random? random}) {
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

    final (
      allUnits,
      unitsByRarity,
    ) = _indexCards<UnitCard>(_expansion.data);
    _allUnits = allUnits;
    _unitsByRarity = unitsByRarity;
  }

  static (List<StyledCard<T>>, Map<Rarity, List<StyledCard<T>>>)
      _indexCards<T extends Card>(
    Iterable<StyledCard> cards,
  ) {
    final all = cards.whereType<StyledCard<T>>().toList();
    return (
      all,
      groupBy<StyledCard<T>, Rarity>(
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

  late final List<StyledCard<LeaderCard>> _allLeaders;
  late final Map<Rarity, List<StyledCard<LeaderCard>>> _leadersByRarity;

  late final List<StyledCard<BaseCard>> _allBases;
  late final Map<Rarity, List<StyledCard<BaseCard>>> _basesByRarity;

  late final List<StyledCard<UnitCard>> _allUnits;
  late final Map<Rarity, List<StyledCard<UnitCard>>> _unitsByRarity;

  StyledCard<LeaderCard> _pullLeader([
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
    } else {
      leaders = leaders
          .where((leader) => leader is! VariantCard<LeaderCard>)
          .toList();
    }

    // If we have no leaders left, we have a problem.
    if (leaders.isEmpty) {
      throw StateError('No leaders left in $expansion.');
    }

    // Pick a random leader.
    return leaders[_random.nextInt(leaders.length)];
  }

  StyledCard<BaseCard> _pullBase([
    Rarity? rarity,
    VariantType? variant,
  ]) {
    // Do we need to filter by rarity?
    var bases = rarity == null
        ? _allBases
        : _basesByRarity[rarity] ??
            (throw StateError('No $rarity bases in $expansion.'));

    // Do we need to filter by variant?
    if (variant != null) {
      bases = bases.where((base) {
        return base is VariantCard<BaseCard> && base.type == variant;
      }).toList();
    } else {
      bases = bases.where((base) => base is! VariantCard<BaseCard>).toList();
    }

    // If we have no bases left, we have a problem.
    if (bases.isEmpty) {
      throw StateError('No bases left in $expansion.');
    }

    // Pick a random base.
    return bases[_random.nextInt(bases.length)];
  }

  StyledCard<UnitCard> _pullUnit([
    Rarity? rarity,
    VariantType? variant,
    bool isFoil = false,
  ]) {
    // Do we need to filter by rarity?
    var units = rarity == null
        ? _allUnits
        : _unitsByRarity[rarity] ??
            (throw StateError('No $rarity units in $expansion.'));

    // Do we need to filter by variant?
    if (variant != null) {
      units = units.where((unit) {
        return unit is VariantCard<UnitCard> && unit.type == variant;
      }).toList();
    } else {
      units = units.where((unit) => unit is! VariantCard<UnitCard>).toList();
    }

    // If we have no units left, we have a problem.
    if (units.isEmpty) {
      throw StateError('No units left in $expansion.');
    }

    // Pick a random unit.
    var result = units[_random.nextInt(units.length)];
    if (isFoil) {
      result = result.withFoil(foil: true);
    }
    return result;
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
  late final _leaders = Dispenser(
    [
      (0.1640, () => _pullLeader(Rarity.rare)),
      (0.1300, () => _pullLeader(Rarity.common, VariantType.hyperspace)),
      (0.0300, () => _pullLeader(Rarity.rare, VariantType.hyperspace)),
      (0.0038, () => _pullLeader(null, VariantType.showcase)),
    ],
    orElse: () => _pullLeader(Rarity.common),
  );

  /// Weighted pull for [BaseCard].
  ///
  /// Type                              | Pull Ratio  | Pull Chance
  /// --------------------------------- | ----------- | ------------
  /// Common                            | Else        | 67.22%
  /// Rare                              | 1:6.1       | 16.40%
  /// Hyperspace Variant (Common)       | 1:6.2       | 16.13%
  late final _bases = Dispenser(
    [
      (0.1640, () => _pullBase(Rarity.rare)),
      (0.1613, () => _pullBase(Rarity.common, VariantType.hyperspace)),
    ],
    orElse: () => _pullBase(Rarity.common),
  );

  /// Weighted pull for [StyledCard.isFoil].
  ///
  /// Type                              | Pull Ratio  | Pull Chance
  /// --------------------------------- | ----------- | ------------
  /// Common                            | Else        | 50.78%
  /// Uncommon                          | 1:4.7       | 21.28%
  /// Rare                              | 1:10.5      | 09.52%
  /// Legendary                         | 1:64.3      | 01.56%
  /// Hyperspace Variant (Common)       | 1:9.3       | 10.75%
  /// Hyperspace Variant (Uncommon)     | 1:27.3      | 03.66%
  /// Hyperspace Variant (Rare)         | 1:64.3      | 01.56%
  /// Hyperspace Variant (Legendary)    | 1:228.8     | 00.44%
  late final _foils = Dispenser(
    [
      (0.2128, () => _pullUnit(Rarity.uncommon, null, true)),
      (0.0952, () => _pullUnit(Rarity.rare, null, true)),
      (0.0156, () => _pullUnit(Rarity.legendary, null, true)),
      (0.1075, () => _pullUnit(Rarity.common, VariantType.hyperspace, true)),
      (0.0366, () => _pullUnit(Rarity.uncommon, VariantType.hyperspace, true)),
      (0.0156, () => _pullUnit(Rarity.rare, VariantType.hyperspace, true)),
      (0.0044, () => _pullUnit(Rarity.legendary, VariantType.hyperspace, true)),
    ],
    orElse: () => _pullUnit(Rarity.common, null, true),
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
    return BoosterPack.withCards(
      leader: _leaders.dispense(_random.nextDouble()),
      base: _bases.dispense(_random.nextDouble()),

      commons: [
        // 8 commons.
        for (var i = 0; i < 8; i++) _pullUnit(Rarity.common),

        // 9th common ... 1:2.8 packs have a hyperspace common.
        if (_random.nextDouble() < 1 / 2.8)
          _pullUnit(Rarity.common, VariantType.hyperspace)
        else
          _pullUnit(Rarity.common),
      ],

      uncommons: [
        // 2 Uncommons.
        for (var i = 0; i < 2; i++) _pullUnit(Rarity.uncommon),

        // 3rd uncommon ... 1:6.6 packs have a hyperspace rare or legendary.
        if (_random.nextDouble() < 1 / 6.6)
          // 1:71.7 it's a legendary.
          if (_random.nextDouble() < 1 / 71.7)
            _pullUnit(Rarity.legendary, VariantType.hyperspace)
          else
            _pullUnit(Rarity.rare, VariantType.hyperspace)
        // Or a 1:8.8 chance of a hyperspace uncommon.
        else if (_random.nextDouble() < 1 / 8.8)
          _pullUnit(Rarity.uncommon, VariantType.hyperspace)
        else
          _pullUnit(Rarity.uncommon),
      ],

      // 1/8 a rare is upgraded to a legendary.
      rareOrLegendary: _random.nextDouble() < 1 / 8
          ? _pullUnit(Rarity.legendary)
          : _pullUnit(Rarity.rare),

      foil: _foils.dispense(_random.nextDouble()),
    );
  }
}
