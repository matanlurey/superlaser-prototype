# Jawa Tool

A specialized command-line tool for working with [Star Wars: Unlimited][].

[star wars: unlimited]: https://starwarsunlimited.com/

## Usage

From the [root of the project](../../), run the following command:

```sh
./bin/jawa --help
```

For example, to download card data from the Star Wars: Unlimited API:

```sh
./bin/jawa scavenge
```

## Development

An "interactive" mode is available for development:

```sh
./bin/jawa --interactive
```

Entering commands in this mode are similar to the regular command-line:

```sh
jawa> scavenge
...
```

> [!NOTE]
> The `--cache` flag is automatically enabled in interactive mode.
