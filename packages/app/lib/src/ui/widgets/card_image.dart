import 'package:flutter/material.dart';
import 'package:foil/foil.dart';
import 'package:unlimited/core.dart' as swu;

/// The type of image to resolve.
enum CardImageType {
  /// The front of the card.
  front(300, 418),

  /// The back of the card.
  back(418, 300),

  /// A thumbnail of the card.
  thumb(300, 100);

  const CardImageType(this.width, this.height);

  /// Width of the image type.
  final int width;

  /// Height of the image type.
  final int height;
}

/// Given a [swu.CardReference], resolves the image for the card.
///
/// The [type] parameter can be used to specify the type of image to resolve.
typedef CardImageResolver = ImageProvider Function(
  swu.CardReference,
  CardImageType type,
);

/// Provides a resolver for card images.
///
/// Cards could be bundled with the app, fetched from a remote server, or cached
/// locally. The [CardImage] widget will look up the image for a card by its
/// [swu.CardReference] and display it.
final class CardImageProvider extends InheritedWidget {
  /// Creates a new [CardImageProvider].
  const CardImageProvider({
    required this.resolve,
    required super.child,
    super.key,
  });

  /// Resolves a card image by its reference.
  final CardImageResolver resolve;

  /// Looks up the [CardImageResolver] from the nearest [BuildContext].
  static CardImageResolver of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<CardImageProvider>()!
        .resolve;
  }

  @override
  bool updateShouldNotify(CardImageProvider oldWidget) {
    return resolve != oldWidget.resolve;
  }
}

/// Displays an image for a card.
final class CardImage extends StatelessWidget {
  /// Creates a new [CardImage].
  const CardImage({
    required this.card,
    this.type = CardImageType.front,
    super.key,
  });

  /// The card to display.
  final swu.CardReference card;

  /// Image type to display.
  final CardImageType type;

  @override
  Widget build(BuildContext context) {
    final resolver = CardImageProvider.of(context);

    Widget child = Image(
      image: resolver(card, type),
      width: type.width.toDouble(),
      height: type.height.toDouble(),
    );
    if (card.foil) {
      child = Foil(opacity: 0.25, child: child);
    }
    return child;
  }
}
