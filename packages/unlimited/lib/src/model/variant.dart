import 'package:meta/meta.dart';
import 'package:unlimited/src/model/card.dart';

/// Represents either a [CanonicalCard] card or a [VariantCard] of a card.
sealed class CardOrVariant {
  const CardOrVariant();
}

/// A canonical card.
@immutable
final class CanonicalCard extends CardOrVariant {
  /// Creates a canonical card with the given [card].
  const CanonicalCard({
    required this.card,
  });

  /// The card.
  final Card card;
}

/// The type of variant.
enum VariantType {
  /// A card with an expanded art border.
  hyperspace,

  /// A (leader) card with an alternative full art style.
  showcase,
}

/// A variant of a card.
final class VariantCard extends CardOrVariant {
  /// Creates a variant with the given [card] and [type].
  const VariantCard({
    required this.number,
    required this.card,
    required this.type,
  });

  /// The variant number.
  final int number;

  /// The card.
  final Card card;

  /// The type of variant.
  final VariantType type;
}
