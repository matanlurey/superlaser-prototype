import 'package:meta/meta.dart';
import 'package:unlimited/src/core/card.dart';

/// Represents either a [CanonicalCard] card or a [VariantCard] of a card.
///
/// ## Comparison
///
/// [StyledCard]s are compared by their [Card.number]s, in ascending order.
///
/// ## Equality
///
/// Two [StyledCard]s are considered equal if their [card] is equal.
@immutable
sealed class StyledCard<T extends Card> implements Comparable<StyledCard<T>> {
  const StyledCard({
    required this.card,
    this.isFoil = false,
  });

  /// Attributes of the card.
  ///
  /// This is the card that this styled card is based on.
  final T card;

  /// Whether this card is a foil.
  final bool isFoil;

  @override
  int compareTo(StyledCard other) {
    return card.number.compareTo(other.card.number);
  }

  @override
  @nonVirtual
  bool operator ==(Object other) {
    return other is StyledCard && other.card == card;
  }

  @override
  @nonVirtual
  int get hashCode => card.hashCode;

  @override
  @nonVirtual
  String toString() => card.toString();

  /// Converts this card or variant to a [CardReference].
  ///
  /// By default, this method will use the [isFoil] attribute to determine
  /// whether the reference should be for a foil card. If [foil] is provided,
  /// it will override the [isFoil] attribute.
  CardReference toReference({bool? foil});

  /// Returns a copy of this card with the [isFoil] attribute set to [foil].
  StyledCard<T> withFoil({required bool foil});
}

/// Extension methods for `StyledCard<LeaderCard>`.
extension StyledLeaderCard on StyledCard<LeaderCard> {
  /// Converts this card to a [StyledCard].
  StyledCard<ArenaCard> toUnit() {
    if (this case final VariantCard<LeaderCard> variant) {
      return VariantCard(
        variantNumber: variant.variantNumber,
        card: variant.card.unit,
        type: variant.type,
        isFoil: variant.isFoil,
      );
    } else {
      return CanonicalCard(card: card.unit, isFoil: isFoil);
    }
  }
}

/// A canonical card.
@immutable
final class CanonicalCard<T extends Card> extends StyledCard<T> {
  /// Creates a canonical card with the given [card].
  const CanonicalCard({
    required super.card,
    super.isFoil,
  });

  @override
  CardReference toReference({bool? foil}) {
    return card.toReference(foil: foil ?? isFoil);
  }

  @override
  CanonicalCard<T> withFoil({required bool foil}) {
    return CanonicalCard(card: card, isFoil: foil);
  }
}

/// The type of variant.
enum VariantType {
  /// A card with an expanded art border.
  hyperspace,

  /// A (leader) card with an alternative full art style.
  showcase,
}

/// A variant of a card.
final class VariantCard<T extends Card> extends StyledCard<T> {
  /// Creates a variant with the given [card] and [type].
  const VariantCard({
    required this.variantNumber,
    required super.card,
    required this.type,
    super.isFoil,
  });

  /// The card number of the card this variant is based on.
  ///
  /// For example, if this variant is a hyperspace variant of card number 5,
  /// then this field will be `5`, while [Card.number] will be the variant's
  /// number.
  final int variantNumber;

  /// The type of variant.
  final VariantType type;

  @override
  CardReference toReference({bool? foil}) {
    return CardReference(
      expansion: card.expansion.code,
      number: variantNumber,
      foil: foil ?? isFoil,
    );
  }

  @override
  VariantCard<T> withFoil({required bool foil}) {
    return VariantCard(
      variantNumber: variantNumber,
      card: card,
      type: type,
      isFoil: foil,
    );
  }
}
