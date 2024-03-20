# Superlaser

A fan-made utility kit for collecting and playing [Star Wars: Unlimited][].

[star wars: unlimited]: https://starwarsunlimited.com/

All of the cards and images are property of their respective owners. This
project is not affiliated with Star Wars: Unlimited or Fantasy Flight Games.

## Repository

### Applications

A [Flutter](https://flutter.dev/) application is in early development in
[`superlaser_app`](./packages/superlaser_app/).

<img 
  alt="Screenshot of the Superlaser app"
  width="300"
  src="https://github.com/matanlurey/superlaser/assets/168174/dce723d5-4314-4d90-ba65-ed3f8b244eba" />

### Data

Raw card data is stored in the [`data`](data/) directory, and is organized by
set.

- Each set has a JSON file with the card data for that set; for example see the
  _Spark of Rebellion_ set in [`data/sor.json`](./data/sor.json).
- A copy of all downloaded images are stored in [`data/assets`](./data/assets/).

To parse the card data, see [`package:scrap`](./packages/scrap/):

> ```dart
> import 'dart:io';
> import 'dart:convert';
> 
> import 'package:jsonut/jsonut.dart';
> import 'package:scrap/scrap.dart';
> 
> void main(List<String> args) {
>   final file = File(args.first);
>   final data = JsonObject.parse(file.readAsStringSync());
>   final expansion = Expansion.fromJson(data);
>   // ...
> }
> ```

> [!NOTE]
> There is no stable format for the card data, and it is subject to change at
> any time.

### Packages

[`package:unlimited`](./packages/unlimited) contains an application agnostic
data model for the game.

### Tools

[`package:jawa`](./packages/jawa) is a command-line tool for managing the card
data and images.

> ```shell
> ./bin/jawa --help
> ```
