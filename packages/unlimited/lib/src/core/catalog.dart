import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:unlimited/core.dart';

/// A collection of expansions and their cards.
///
/// This class is used to provide a convenient way to look up and reference
/// cards across multiple releases.
@immutable
final class Catalog {
  /// Creates a catalog from the given [expansions].
  ///
  /// The [expansions] must be:
  /// - Non-empty;
  /// - Unique based on [CatalogExpansion.expansion];
  /// - Sorted by [Expansion] comparison.
  factory Catalog.from(Iterable<CatalogExpansion> expansions) {
    final list = expansions.toList(growable: false);
    _checkUniqueAndSorted(list);
    return Catalog._({
      for (final expansion in list) expansion.expansion.code: expansion,
    });
  }

  Catalog._(this._expansions)
      : _lookupCache = {
          for (final expansion in _expansions.values)
            for (final data in expansion.data) data.toReference(): data,
        };

  static void _checkUniqueAndSorted(List<CatalogExpansion> expansions) {
    if (expansions.isEmpty) {
      throw ArgumentError.value(
        expansions,
        'expansions',
        'Must not be empty',
      );
    }
    var last = Expansion.values.first;
    for (final expansion in expansions.skip(1)) {
      if (expansion.expansion.compareTo(last) <= 0) {
        throw ArgumentError.value(
          expansion,
          'expansions',
          'All expansions must be unique and sorted',
        );
      }
      last = expansion.expansion;
    }
  }

  final Map<String, CatalogExpansion> _expansions;

  /// All expansions in the catalog in sorted order.
  ///
  /// The list is unmodifiable.
  late final expansions = List<CatalogExpansion>.unmodifiable(
    _expansions.values,
  );

  /// All cards in the catalog, ignoring variants, in sorted order.
  Iterable<Card> get allCards {
    return _expansions.values
        .expand((expansion) => expansion.data)
        .whereType<CanonicalCard>()
        .map((wrapper) => wrapper.card);
  }

  final Map<CardReference, StyledCard> _lookupCache;

  /// Looks up a card by its [reference], or `null` if no such card exists.
  ///
  /// [CardReference.foil] is ignored.
  ///
  /// ## Performance
  ///
  /// The performance of this method is `O(1)`.
  StyledCard? lookup(CardReference reference) {
    reference = reference.withFoil(foil: false);
    return _lookupCache[reference];
  }

  /// Looks up a card by its [reference], and resolves variants to their card.
  ///
  /// [CardReference.foil] is ignored.
  ///
  /// An error is thrown if the card is not found.
  ///
  /// ## Performance
  ///
  /// The performance of this method is `O(1)`.
  Card lookupAndResolve(CardReference reference) {
    final data = lookup(reference);
    if (data == null) {
      throw ArgumentError.value(
        reference,
        'reference',
        'No such card in the catalog',
      );
    }
    return data.card;
  }

  @override
  String toString() => 'Catalog <${_expansions.length} expansions>';
}

/// Provides cataloged information about a specific [expansion].
@immutable
final class CatalogExpansion {
  /// Creates a catalog expansion for the given [expansion] and [data].
  ///
  /// The [data] must be:
  /// - Non-empty;
  /// - All be a member of the same [expansion];
  /// - Unique based on [Card.number];
  /// - Sorted by [Card.number].
  ///
  /// **TIP**: [StyledCard] is _comparable_, so you can use `sort()`:
  /// ```dart
  /// CatalogExpansion([...]..sort());
  /// ```
  CatalogExpansion(Iterable<StyledCard> data)
      : _data = data.toList(growable: false),
        expansion = data.first.card.expansion {
    if (_data.isEmpty) {
      throw ArgumentError.value(
        data,
        'cards',
        'Must not be empty',
      );
    }
    late Card lastCard;
    var last = 0;
    for (final (i, wrapper) in _data.indexed) {
      final card = wrapper.card;
      if (card.expansion != expansion) {
        throw ArgumentError.value(
          '$card',
          'cards',
          'All cards must belong to the same expansion (${expansion.code})',
        );
      }
      final number = switch (wrapper) {
        final CanonicalCard c => c.card.number,
        final VariantCard v => v.variantNumber,
      };
      if (number <= last) {
        throw ArgumentError.value(
          '$card',
          'cards[$i]',
          'All cards must have a unique number and be sorted by number (last: $lastCard, next: #$number (${wrapper.runtimeType}) -> $card)',
        );
      }
      last = number;
      lastCard = card;
    }
  }

  /// Which expansion to add to the catalog.
  final Expansion expansion;

  /// Cards (and variants) that belong to the expansion.
  ///
  /// The cards are sorted by [Card.number], such that for a full release (all
  /// cards in a single expansion), the card at index `i` has number `i + 1`:
  ///
  /// ```dart
  /// final expansion = CatalogExpansion(...);
  /// for (var i = 0; i < expansion.cards.length; i++) {
  ///   print(expansion.data[i].card.number == i + 1); // true
  /// }
  /// ```
  ///
  /// **WARNING**: In practice, this is not always true, as some expansions
  /// will be partial releases, and some cards may be missing. Use the [lookup]
  /// method to reliably find cards by number:
  ///
  /// ```dart
  /// final card = expansion.lookup(42);
  /// ```
  ///
  /// The list is unmodifiable.
  late final data = List<StyledCard>.unmodifiable(_data);
  final List<StyledCard> _data;

  /// Looks up a card by its number, or `null` if no such card exists.
  ///
  /// ## Performance
  ///
  /// The performance of this method is `O(log n)` where `n` is the number of
  /// cards in the expansion. This is because the cards are sorted by number,
  /// and the method uses a [binary search] to find the card.
  ///
  /// This is expected to be sufficiently fast for most use cases, but if you
  /// need to look up cards by number frequently, consider caching the results
  /// (this is done automatically by the [Catalog] class).
  ///
  /// [binary search]: https://en.wikipedia.org/wiki/Binary_search_algorithm
  StyledCard? lookup(int number) {
    var min = 0;
    var max = _data.length - 1;
    while (min <= max) {
      final mid = min + ((max - min) >> 1);
      final target = switch (_data[mid]) {
        final CanonicalCard c => c.card.number,
        final VariantCard v => v.variantNumber,
      };
      if (target < number) {
        min = mid + 1;
      } else if (target > number) {
        max = mid - 1;
      } else {
        return _data[mid];
      }
    }
    return null;
  }

  @override
  String toString() => 'CatalogExpansion <$expansion, ${data.length} cards>';
}
