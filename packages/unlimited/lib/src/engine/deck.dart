import 'package:collection/collection.dart';
import 'package:unlimited/core.dart';

/// A pre-built deck.
///
/// Depending on the game mode, a deck has different construction constraints.
sealed class Deck {
  Deck({
    required this.base,
    required Iterable<DeckCard> cards,
  }) : cards = List<DeckCard>.unmodifiable(cards) {
    if (!this.cards.isSorted((a, b) => a.compareTo(b))) {
      throw ArgumentError('Cards must be ordered by [Card.compareTo].');
    }
  }

  /// Throws if the given [cards] have no more than [maxCopies] of any one card.
  static void checkMaxCopies(Iterable<DeckCard> cards, {int maxCopies = 3}) {
    final list = cards.toList();
    var count = 0;
    for (var i = 0; i < list.length; i++) {
      if (i == 0 || list[i] != list[i - 1]) {
        count = 1;
      } else {
        count++;
      }
      if (count > 3) {
        throw RangeError.value(
          i,
          'cards',
          'Cannot have more than $maxCopies copies of ${list[i]}.',
        );
      }
    }
  }

  /// The base card for the deck.
  final BaseCard base;

  /// The cards in the deck.
  ///
  /// Cards must be ordered by [Card.compareTo].
  final List<DeckCard> cards;
}

/// The primary format of Competitive-tier Organized Play events.
///
/// See <https://starwarsunlimited.com/how-to-play?chapter=premier>.
///
/// Each deck consists of:
/// - exactly 1 [base] card;
/// - exactly 1 [leader] card;
/// - minimum 50 [cards] draw deck
/// - an optional [sideboard] of up to 10 non-leader/non-base cards.
///
/// Your draw deck cannot include more than three copies of any one card.
final class PremierDeck extends Deck {
  /// Creates a new Premier deck from the given [base], [leader], and [cards].
  ///
  /// The [sideboard] is optional and defaults to an empty list.
  PremierDeck({
    required super.base,
    required super.cards,
    required this.leader,
    this.sideboard = const [],
  }) {
    if (cards.length < 50) {
      throw ArgumentError.value(
        cards.length,
        'cards',
        'Must have at least 50 cards.',
      );
    }

    // Check if there are more than 3 copies of any one card.
    Deck.checkMaxCopies(cards);

    // If a sideboard is provided, check the length is at most 10.
    if (sideboard.length > 10) {
      throw ArgumentError.value(
        sideboard.length,
        'sideboard',
        'Cannot have more than 10 cards.',
      );
    }
  }

  /// The leader card for the deck.
  final LeaderCard leader;

  /// The sideboard cards for the deck.
  final List<DeckCard> sideboard;

  /// The cards in the deck.
  ///
  /// Cards must be ordered by [Card.compareTo].
  ///
  /// Minimum of 50 cards, and no more than 3 copies of any one card.
  @override
  List<DeckCard> get cards => super.cards;
}

/// A deck constructed from a limited pool of cards such as _draft_ or _sealed_.
///
/// See:
/// - <https://starwarsunlimited.com/how-to-play?chapter=draft-play>
/// - <https://starwarsunlimited.com/how-to-play?chapter=sealed-play>
///
/// Each deck consists of:
/// - exactly 1 [base] card;
/// - exactly 1 [leader] card;
/// - at least 30 [cards] draw deck.
///
/// There are no copy limits for cards in a limited deck.
final class LimitedDeck extends Deck {
  /// Creates a new Limited deck from the given [base], [leader], and [cards].
  LimitedDeck({
    required super.base,
    required super.cards,
    required this.leader,
  }) {
    if (cards.length < 30) {
      throw ArgumentError.value(
        cards.length,
        'cards',
        'Must have at least 30 cards.',
      );
    }
  }

  /// The leader card for the deck.
  final LeaderCard leader;

  /// The cards in the deck.
  ///
  /// Cards must be ordered by [Card.compareTo].
  ///
  /// Minimum of 30 cards, and no copy limits.
  @override
  List<DeckCard> get cards => super.cards;
}

/// The primary multiplayer format of Star Wars: Unlimited.
///
/// See <https://starwarsunlimited.com/how-to-play?chapter=twin-suns>.
///
/// Each deck consists of:
/// - exactly 1 [base] card;
/// - exactly 2 [leaders] that share [Aspect.heroism] or [Aspect.villainy];
/// - minimum 50[^1] [cards] draw deck.
///
/// You cannot have more than 1 copy of any one card in your deck.
///
/// [^1]: The minimum deck size will increase as more sets are released.
final class TwinSunsDeck extends Deck {
  /// Creates a new Twin Suns deck from the given [base], [leaders], and [cards].
  TwinSunsDeck({
    required super.base,
    required super.cards,
    required Iterable<LeaderCard> leaders,
  }) : leaders = List<LeaderCard>.unmodifiable(leaders) {
    if (cards.length < 50) {
      throw ArgumentError.value(
        cards.length,
        'cards',
        'Must have at least 50 cards.',
      );
    }

    if (this.leaders.length != 2) {
      throw ArgumentError.value(
        this.leaders.length,
        'leaders',
        'Must have exactly 2 leaders.',
      );
    }

    // Check if the leaders share the same moral aspect.
    if (this.leaders[0].aspects.moral != this.leaders[1].aspects.moral) {
      throw ArgumentError.value(
        leaders,
        'leaders',
        'Must share the same moral aspect.',
      );
    }

    // Check if there are more than 1 copy of any one card.
    Deck.checkMaxCopies(cards, maxCopies: 1);
  }

  /// The leader cards for the deck.
  ///
  /// The leaders must share the same [Aspect].
  ///
  /// The list is unmodifiable.
  final List<LeaderCard> leaders;

  /// The cards in the deck.
  ///
  /// Cards must be ordered by [Card.compareTo].
  ///
  /// Minimum of 50 cards, and no more than 1 copy of any one card.
  @override
  List<DeckCard> get cards => super.cards;
}
