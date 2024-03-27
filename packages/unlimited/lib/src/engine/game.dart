import 'package:meta/meta.dart';
import 'package:unlimited/engine.dart';

/// Player-specific state.
@immutable
final class PlayerState {
  const PlayerState._({
    required this.baseZone,
    required this.resourceZone,
    required this.handZone,
    required this.deckZone,
    required this.discardPileZone,
  });

  /// Creates a new player state from the initial state.
  ///
  /// Bases and leaders are automatically put into play.
  factory PlayerState.fromInitialState(InitialPlayerState state) {
    return PlayerState._(
      baseZone: BaseZone(
        base: Base.fromCard(state.deck.base),
        leaders: state.deck.leaders.map(Leader.fromCard),
      ),
      resourceZone: ResourceZone(),
      handZone: HandZone(),
      deckZone: DeckZone.withCards(state.deck.cards),
      discardPileZone: DiscardPileZone(),
    );
  }

  /// The base zone for the player.
  final BaseZone baseZone;

  /// The resource zone for the player.
  final ResourceZone resourceZone;

  /// The hand zone for the player.
  final HandZone handZone;

  /// The deck zone for the player.
  final DeckZone deckZone;

  /// The discard pile zone for the player.
  final DiscardPileZone discardPileZone;

  /// Returns a copy of the player state with the provided zones replaced.
  PlayerState copyWith({
    BaseZone Function(BaseZone)? base,
    ResourceZone Function(ResourceZone)? resource,
    HandZone Function(HandZone)? hand,
    DeckZone Function(DeckZone)? deck,
    DiscardPileZone Function(DiscardPileZone)? discardPile,
  }) {
    return PlayerState._(
      baseZone: base?.call(baseZone) ?? baseZone,
      resourceZone: resource?.call(resourceZone) ?? resourceZone,
      handZone: hand?.call(handZone) ?? handZone,
      deckZone: deck?.call(deckZone) ?? deckZone,
      discardPileZone: discardPile?.call(discardPileZone) ?? discardPileZone,
    );
  }
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
@immutable
final class Game {
  Game._({
    required Map<Player, PlayerState> players,
    required this.groundArena,
    required this.spaceArena,
  }) : players = Map.unmodifiable(players);

  /// Creates a game from existing state.
  factory Game.from({
    required Map<Player, PlayerState> players,
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

  /// Returns a copy of the game with the ground arena replaced.
  @useResult
  Game withGroundArena(GroundArenaZone groundArena) {
    return Game.from(
      players: players,
      groundArena: groundArena,
      spaceArena: spaceArena,
    );
  }

  /// Returns a copy of the game with the space arena replaced.
  @useResult
  Game withSpaceArena(SpaceArenaZone spaceArena) {
    return Game.from(
      players: players,
      groundArena: groundArena,
      spaceArena: spaceArena,
    );
  }

  /// Returns a copy of the game with the specified player's state replaced.
  @useResult
  Game withPlayerState(Player player, PlayerState Function(PlayerState) fn) {
    return Game.from(
      players: Map.unmodifiable({
        ...players,
        player: fn(players[player]!),
      }),
      groundArena: groundArena,
      spaceArena: spaceArena,
    );
  }
}
