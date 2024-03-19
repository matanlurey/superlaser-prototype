# Todo

Project-wide TODOs before there is a need for an issue tracker.

## Must do

_None_.

## Next up

- [ ] Start collection management tool (`package:superlaser_app`).
  - [ ] Add cards to collection (`###`) with optional foil toggle (`f###`).
  - [ ] Automatically load `collection.csv` (if it exists) from storage.
  - [ ] Automatically save to disk.
  - [ ] Explicit import/export to CSV file.

- [x] Create `packages/unlimited`:
  - [x] Add `lib/model.dart` with the core data model.
  - [ ] Add `lib/sets/sor.dart` with the _Spark of Rebellion_ set and starters.
  - [ ] Add `lib/table.dart` with a simulated table model.
  - [ ] Add `lib/interop.dart` with [popular](docs/external.md) format export/import codecs.

## Nice to have

- [ ] Store and download alternate artwork for games.
- [ ] Store description text for cards.
