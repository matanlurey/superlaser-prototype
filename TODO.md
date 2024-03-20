# Todo

Project-wide TODOs before there is a need for an issue tracker.

## Must do

_None_.

## Next up

- [x] Add variants to the scraped data model:
  - [x] Change the `art` scraped field to be a single object not a list:

    ```jsonc
    "art": {
      "kind": "standard",
      "artist": "John Doe",
      "front": {
        /* ... */
      },
      /* ... */
    }
    ```

  - [x] Extend the data model:

    ```jsonc
    "variants": {
      "hyperspace": {
        "number": 253,
        "art": {
          /*...*/
        },
      },
      "showcase": {
        "number": 254,
        "art": {
          /*...*/
        },
      },
    }
    ```

- [x] Start collection management tool (`package:superlaser_app`).
  - [x] Add cards to collection (`###`) with optional foil toggle (`f###`).
  - [x] Automatically load `collection.json` (if it exists) from storage.
  - [x] Automatically save to disk.
  - [ ] Explicit import/export to json file.

- [x] Create `packages/unlimited`:
  - [x] Add `lib/model.dart` with the core data model.
  - [ ] Add `lib/sets/sor.dart` with the _Spark of Rebellion_ set and starters.
  - [ ] Add `lib/table.dart` with a simulated table model.
  - [ ] Add `lib/interop.dart` with [popular](docs/external.md) format export/import codecs.

## Nice to have

- [ ] Store and download alternate artwork for games.
- [ ] Store description text for cards.
