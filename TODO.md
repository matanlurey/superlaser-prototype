# Todo

Project-wide TODOs before there is a need for an issue tracker.

## Next up

- [ ] Units with duplicate names (i.e. `lukeSkywalkerJediKnight`) are missing in
      the catalogs, overriden by their leader-equivalents (i.e. `lukeSkywalker`),
      this is a BUG (in `retrofit` codegen).

- [ ] Add `package:unlimited/engine.dart` with a simulated gameplay model:
  - [ ] Zones that can contain cards:
    - [ ] Base
    - [ ] Ground, Space (Shared)
    - [ ] Resource
    - [ ] Deck
    - [ ] Hand
    - [ ] Discard Pile
    - [ ] In-Play/Out of Play
    - [ ] Play Area
    - [ ] Set Aside/Being in no zone
  - [ ] Game structure
    - [ ] Starting the game and setup
    - [ ] Round
    - [ ] Action phase
    - [ ] Regroup phase
    - [ ] Ending the game

## Lower priority

- [ ] Replace `sor.cards` with a higher-level data structure than a `List<>`.
- [ ] Add `package:unlimited/interop.dart` with [popular](docs/external.md) format export/import codecs.

## Nice to have

- [ ] Store and download alternate artwork for games.
- [ ] Store description text for cards.
