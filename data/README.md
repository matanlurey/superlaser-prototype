# Raw Card Data

The source of truth.

Code generation and various other techniques are used throughout the project to
utilize this data, so unlike other forms of caching, this data _is_ checked into
version control and expected to be hermetic.

## Usage

The data in this directory can be parsed using [`scrap`](../packages/scrap/).

## Regeneration

To regenerate this data, run from the [root of the project](../../):

```sh
./bin/jawa scavenge
```

This normally only needs to be run if:

- New sets are released
- The API has changed
- The storage schema has changed
