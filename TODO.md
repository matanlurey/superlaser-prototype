# Todo

Project-wide TODOs before there is a need for an issue tracker.

## Next up

- [x] Units with duplicate names (i.e. `lukeSkywalkerJediKnight`) are missing in
      the catalogs, overriden by their leader-equivalents (i.e. `lukeSkywalker`),
      this is a BUG (in `retrofit` codegen).
- [x] Something wrong with encoding of strings (i.e. Chirrut's name). I think
      this is also in both `scavenge` and `retrofit` codegen, the names are
      already messed up by the time they are in `cards.json`.

      The name is already wrong in-memory in `scavenge`: `-> Card 4/252: Chirrut Ãmwe (4263394087).`

      It's fine in the HTTP logs, so cache problem: `"title": "Chirrut Îmwe",`.

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
