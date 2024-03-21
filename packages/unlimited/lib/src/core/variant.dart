import 'package:meta/meta.dart';
import 'package:unlimited/src/core/card.dart';

/// Represents either a [CanonicalCard] card or a [VariantCard] of a card.
///
/// ## Comparison
///
/// [CardOrVariant]s are compared by their [Card.number]s, in ascending order.
///
/// ## Equality
///
/// Two [CardOrVariant]s are considered equal if their [card] is equal.
@immutable
sealed class CardOrVariant implements Comparable<CardOrVariant> {
  const CardOrVariant({
    required this.card,
  });

  /// The card.
  final Card card;

  @override
  int compareTo(CardOrVariant other) {
    return card.number.compareTo(other.card.number);
  }

  @override
  @nonVirtual
  bool operator ==(Object other) {
    return other is CardOrVariant && other.card == card;
  }

  @override
  @nonVirtual
  int get hashCode => card.hashCode;

  @override
  @nonVirtual
  String toString() => card.toString();
}

/// A canonical card.
@immutable
final class CanonicalCard extends CardOrVariant {
  /// Creates a canonical card with the given [card].
  const CanonicalCard({
    required super.card,
  });
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
    required this.variantNumber,
    required super.card,
    required this.type,
  });

  /// The card number of the card this variant is based on.
  ///
  /// For example, if this variant is a hyperspace variant of card number 5,
  /// then this field will be `5`, while [Card.number] will be the variant's
  /// number.
  final int variantNumber;

  /// The type of variant.
  final VariantType type;
}
