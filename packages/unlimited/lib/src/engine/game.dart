import 'package:meta/meta.dart';
import 'package:unlimited/engine.dart';

/// Player-specific state.
@immutable
final class PlayerState {
  const PlayerState._({
    required this.base,
    required this.resources,
    required this.hand,
    required this.deck,
    required this.discardPile,
  });

  /// Creates a new player state from the initial state.
  factory PlayerState.fromInitialState(InitialPlayerState state) {
    return PlayerState._(
      base: BaseZone(
        base: Base.fromCard(state.deck.base),
        leaders: state.deck.leaders.map(Leader.fromCard),
      ),
      resources: ResourceZone(),
      hand: HandZone(),
      deck: DeckZone.withCards(state.deck.cards),
      discardPile: DiscardPileZone(),
    );
  }

  /// The base zone for the player.
  final BaseZone base;

  /// The resource zone for the player.
  final ResourceZone resources;

  /// The hand zone for the player.
  final HandZone hand;

  /// The deck zone for the player.
  final DeckZone deck;

  /// The discard pile zone for the player.
  final DiscardPileZone discardPile;
}

/// Initial player-specific state.
@immutable
final class InitialPlayerState<T extends Deck> {
  /// Creates a new initial player state.
  InitialPlayerState({
    required this.player,
    required this.deck,
  });

  /// The player.
  final Player player;

  /// The player's deck.
  final T deck;
}

/// Game structure for the [Star Wars: Unlimited] Trading Card Game.
///
/// A game consists of multiple [rounds], and each round consists of an action
/// phase and a regroup phase. During the action phase, players take turns
/// taking an action. During the regroup phase, players can put a resource into
/// play and ready exhausted cards.
@immutable
final class Game {
  Game._({
    required Map<Player, PlayerState> players,
    required this.rounds,
    required this.groundArena,
    required this.spaceArena,
  }) : players = Map.unmodifiable(players);

  /// Creates a game from existing state.
  factory Game.from({
    required Map<Player, PlayerState> players,
    required int rounds,
    required GroundArenaZone groundArena,
    required SpaceArenaZone spaceArena,
  }) = Game._;

  factory Game._new(
    InitialPlayerState a,
    InitialPlayerState b,
  ) {
    final aState = PlayerState.fromInitialState(a);
    final bState = PlayerState.fromInitialState(b);
    return Game._(
      players: {
        a.player: aState,
        b.player: bState,
      },
      rounds: 0,
      groundArena: GroundArenaZone(),
      spaceArena: SpaceArenaZone(),
    );
  }

  /// Creates a new game between two players using [PremierDeck]s.
  factory Game.newPremier(
    InitialPlayerState<PremierDeck> a,
    InitialPlayerState<PremierDeck> b,
  ) = Game._new;

  /// Creates a new game between two players using [LimitedDeck]s.
  factory Game.newLimited(
    InitialPlayerState<LimitedDeck> a,
    InitialPlayerState<LimitedDeck> b,
  ) = Game._new;

  /// The shared ground arena for the game.
  final GroundArenaZone groundArena;

  /// The shared space arena for the game.
  final SpaceArenaZone spaceArena;

  /// Individual state for each player.
  final Map<Player, PlayerState> players;

  /// How many rounds have been played.
  ///
  /// See also: [currentRound].
  final int rounds;

  /// The current round of the game.
  @nonVirtual
  int get currentRound => rounds + 1;
}
