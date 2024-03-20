import 'dart:collection';
import 'dart:convert';
import 'dart:io' as io;

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jawa/src/tools/cached_http_client.dart';
import 'package:jawa/src/tools/swu_api.dart';
import 'package:jsonut/jsonut.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:scrap/scrap.dart';

/// Provides the ability to scrape JSON and images from the web.
final class Scavenge extends Command<void> {
  /// Creates a new [Scavenge] command.
  ///
  /// - [interactive] is whether the command is running in an interactive shell.
  /// - [projectRoot] is the root directory of the project.
  Scavenge({
    required bool interactive,
    required String projectRoot,
  }) {
    addSubcommand(_Images(projectRoot: projectRoot));
    addSubcommand(_Json(projectRoot: projectRoot, interactive: interactive));
  }
  @override
  String get name => 'scavenge';

  @override
  String get description => 'Scrapes the web for card data.';
}

final class _Json extends Command<void> {
  _Json({
    required bool interactive,
    required this.projectRoot,
  }) {
    argParser
      ..addFlag(
        'cache',
        abbr: 'c',
        help: 'Whether to use a cache instead of fetching data, if available.',
        defaultsTo: interactive,
      )
      ..addOption(
        'output',
        abbr: 'o',
        help: 'The output directory for the artifacts.',
        defaultsTo: p.join(projectRoot, 'data'),
      );
  }
  @override
  String get name => 'json';

  @override
  String get description => 'Scrapes the web for card data.';

  final String projectRoot;

  @override
  @protected
  ArgResults get argResults => super.argResults!;

  @override
  Future<void> run() async {
    final (cache, output) = (
      argResults['cache'] as bool,
      argResults['output'] as String,
    );

    var client = http.Client();
    if (cache) {
      final cacheDir = io.Directory(p.join(projectRoot, '.cache', 'swu-api'));
      io.stderr.writeln('Using cache at ${cacheDir.path}.');
      client = await CachedHttpClient.using(cacheDir, client);
    }

    try {
      final api = SwuApiClient(client);
      final sets = <String, _ExpansionBuilder>{};

      await for (final data in api.fetchAllCards()) {
        io.stderr.writeln(
          'Fetched page ${data.pagination.page} of '
          '${data.pagination.pageCount}.',
        );

        for (final data in data.cards) {
          if (data.cardNumber == 0 || data.isVariant) {
            // Skip tokens and variants.
            continue;
          }
          io.stderr.writeln(
            '-> Card ${data.cardNumber}/${data.cardCount}: ${data.title} '
            '(${data.cardUid}).',
          );

          final Card card;
          final art = Art(
            artist: data.artist,
            front: ArtImage(
              url: Uri.parse(data.artFront.url),
              width: data.artFront.width,
              height: data.artFront.height,
            ),
            back: data.artBack != null
                ? ArtImage(
                    url: Uri.parse(data.artBack!.url),
                    width: data.artBack!.width,
                    height: data.artBack!.height,
                  )
                : null,
            thumbnail: ArtImage(
              url: Uri.parse(data.artThumbnail.url),
              width: data.artThumbnail.width,
              height: data.artThumbnail.height,
            ),
          );

          Variants? variants() {
            if (data.variants == null) {
              return null;
            }
            Variant? showcase;
            Variant? hyperspace;
            for (final c in data.variants!.cards) {
              if (c.hyperspace) {
                hyperspace = Variant(
                  number: c.cardNumber,
                  art: Art(
                    artist: c.artist,
                    front: ArtImage(
                      url: Uri.parse(c.artFront.url),
                      width: c.artFront.width,
                      height: c.artFront.height,
                    ),
                    back: c.artBack != null
                        ? ArtImage(
                            url: Uri.parse(c.artBack!.url),
                            width: c.artBack!.width,
                            height: c.artBack!.height,
                          )
                        : null,
                    thumbnail: ArtImage(
                      url: Uri.parse(c.artThumbnail.url),
                      width: c.artThumbnail.width,
                      height: c.artThumbnail.height,
                    ),
                  ),
                );
              } else if (c.showcase) {
                showcase = Variant(
                  number: c.cardNumber,
                  art: Art(
                    artist: c.artist,
                    front: ArtImage(
                      url: Uri.parse(c.artFront.url),
                      width: c.artFront.width,
                      height: c.artFront.height,
                    ),
                    back: c.artBack != null
                        ? ArtImage(
                            url: Uri.parse(c.artBack!.url),
                            width: c.artBack!.width,
                            height: c.artBack!.height,
                          )
                        : null,
                    thumbnail: ArtImage(
                      url: Uri.parse(c.artThumbnail.url),
                      width: c.artThumbnail.width,
                      height: c.artThumbnail.height,
                    ),
                  ),
                );
              } else {
                // TODO: Support promotional variants.
                // Example: https://cdn.starwarsunlimited.com//card_SWOP_0103_018_Greedo_OP_55b8cb8698.png.
                io.stderr.writeln(
                  'Unknown variant: ${c.cardUid} (${c.cardNumber}).',
                );
              }
            }
            return Variants(
              showcase: showcase,
              hyperspace: hyperspace,
            );
          }

          switch (data.type.name) {
            case 'Leader':
              card = LeaderCard(
                title: data.title,
                number: data.cardNumber,
                art: art,
                variants: variants(),
                rarity: Rarity.fromName(data.rarity.name.toLowerCase()),
                aspects: Aspects.from(
                  data.aspects.map(
                    (a) => Aspect.fromName(a.name.toLowerCase()),
                  ),
                ),
                traits: data.traits.toSet(),
                arena: Arena.fromName(data.arenas.single.toLowerCase()),
                subTitle: data.subTitle!,
                cost: data.cost!,
                health: data.hp!,
                power: data.power!,
                unique: data.unique,
              );
            case 'Base':
              card = BaseCard(
                title: data.title,
                number: data.cardNumber,
                art: art,
                variants: variants(),
                rarity: Rarity.fromName(data.rarity.name.toLowerCase()),
                aspects: Aspects.from(
                  data.aspects.map(
                    (a) => Aspect.fromName(a.name.toLowerCase()),
                  ),
                ),
                health: data.hp!,
                unique: data.unique,
              );
            case 'Unit':
              card = UnitCard(
                title: data.title,
                number: data.cardNumber,
                art: art,
                variants: variants(),
                rarity: Rarity.fromName(data.rarity.name.toLowerCase()),
                aspects: Aspects.from(
                  data.aspects.map(
                    (a) => Aspect.fromName(a.name.toLowerCase()),
                  ),
                ),
                traits: data.traits.toSet(),
                arena: Arena.fromName(data.arenas.single.toLowerCase()),
                subTitle: data.subTitle,
                cost: data.cost!,
                health: data.hp!,
                power: data.power!,
                unique: data.unique,
              );
            case 'Upgrade':
              card = UpgradeCard(
                title: data.title,
                number: data.cardNumber,
                art: art,
                variants: variants(),
                rarity: Rarity.fromName(data.rarity.name.toLowerCase()),
                aspects: Aspects.from(
                  data.aspects.map(
                    (a) => Aspect.fromName(a.name.toLowerCase()),
                  ),
                ),
                traits: data.traits.toSet(),
                cost: data.cost!,
                unique: data.unique,
              );
            case 'Event':
              card = EventCard(
                title: data.title,
                number: data.cardNumber,
                art: art,
                variants: variants(),
                rarity: Rarity.fromName(data.rarity.name.toLowerCase()),
                aspects: Aspects.from(
                  data.aspects.map(
                    (a) => Aspect.fromName(a.name.toLowerCase()),
                  ),
                ),
                traits: data.traits.toSet(),
                cost: data.cost!,
                unique: data.unique,
              );
            default:
              io.stderr.writeln(
                'Unknown card type: ${data.type.name} (${data.cardUid}).',
              );
              continue;
          }

          sets
              .putIfAbsent(
                data.expansion.code,
                () => _ExpansionBuilder(
                  name: data.expansion.name,
                  code: data.expansion.code,
                  count: data.cardCount,
                ),
              )
              .cards
              .add(card);
        }
      }

      io.stderr.writeln('Fetched ${sets.length} expansions:');
      for (final set in sets.values) {
        io.stderr.writeln(
          '-> ${set.name} (${set.code}): ${set.cards.length} cards',
        );
      }

      // Save expansions to output directory.
      final outputDir = io.Directory(output);
      await outputDir.create(recursive: true);
      for (final set in sets.values) {
        final expansion = set.build();
        final file = io.File(p.join(outputDir.path, '${set.code}.json'));
        await file.writeAsString(
          const JsonEncoder.withIndent('  ').convert(
            expansion.toJson(),
          ),
        );
      }
    } finally {
      client.close();
    }
  }
}

@immutable
final class _ExpansionBuilder {
  _ExpansionBuilder({
    required this.name,
    required this.code,
    required this.count,
  }) : cards = [];

  final String name;
  final String code;
  final int count;
  final List<Card> cards;

  @override
  bool operator ==(Object other) {
    return other is _ExpansionBuilder && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;

  Expansion build() {
    return Expansion(
      name: name,
      code: code.toLowerCase(),
      count: count,
      cards: cards,
    );
  }
}

final class _Images extends Command<void> {
  _Images({
    required this.projectRoot,
  }) {
    argParser
      ..addOption(
        'input',
        abbr: 'i',
        help: 'The input directory for the artifacts.',
        defaultsTo: p.join(projectRoot, 'data'),
      )
      ..addOption(
        'output',
        abbr: 'o',
        help: 'The output directory for the images.',
        defaultsTo: p.join(projectRoot, 'data', 'assets'),
      );
  }
  @override
  String get name => 'images';

  @override
  String get description => 'Downloads card images.';

  final String projectRoot;

  @override
  @protected
  ArgResults get argResults => super.argResults!;

  @override
  Future<void> run() async {
    final (input, output) = (
      argResults['input'] as String,
      argResults['output'] as String,
    );

    final inputDir = io.Directory(input);
    final outputDir = io.Directory(output);
    await outputDir.create(recursive: true);

    final downloads = <_Download>{};
    await for (final file in inputDir.list()) {
      if (file is io.File && file.path.endsWith('.json')) {
        final expansion = Expansion.fromJson(
          JsonObject.parse(await file.readAsString()),
        );

        final expansionDir = io.Directory(
          p.join(outputDir.path, expansion.code),
        );
        await expansionDir.create(recursive: true);
        final maxDigits = '${expansion.count}'.length;

        for (final card in expansion.cards) {
          final number = card.number.toString().padLeft(maxDigits, '0');

          // TODO: Add variants.
          for (final art in [card.art]) {
            downloads.add(
              _Download(
                url: art.front.url,
                file: io.File(
                  p.join(expansionDir.path, '$number.front.png'),
                ),
              ),
            );
            if (art.back != null) {
              downloads.add(
                _Download(
                  url: art.back!.url,
                  file: io.File(
                    p.join(expansionDir.path, '$number.back.png'),
                  ),
                ),
              );
            }
            downloads.add(
              _Download(
                url: art.thumbnail.url,
                file: io.File(
                  p.join(expansionDir.path, '$number.thumb.png'),
                ),
              ),
            );
          }
        }
      }
    }

    final client = http.Client();
    final queue = Queue<_Download>.of(downloads);
    try {
      while (queue.isNotEmpty) {
        // Download 10 images at a time.
        final fetch = [
          for (var i = 0; i < 10 && queue.isNotEmpty; i++) queue.removeFirst(),
        ];
        await Future.wait(
          fetch.map((d) => d.fetch(client, cache: true)),
        );
        io.stderr.writeln('Remaining: ${queue.length}');
      }
    } finally {
      client.close();
    }
  }
}

@immutable
final class _Download {
  /// Creates a new pending download.
  ///
  /// - [url] is the URL of the file to download.
  /// - [file] is the file to save the downloaded data to.
  const _Download({
    required this.url,
    required this.file,
  });

  final Uri url;
  final io.File file;

  @override
  bool operator ==(Object other) {
    return other is _Download && other.url == url;
  }

  @override
  int get hashCode => url.hashCode;

  static final _dateFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss zzz');

  Future<void> fetch(http.Client client, {bool cache = false}) async {
    String? ifModifiedSince;
    if (cache && await file.exists()) {
      ifModifiedSince = _dateFormat.format(await file.lastModified());
    }
    final response = await client.get(
      url,
      headers: {
        if (ifModifiedSince != null) ...{
          'Cache-Control': 'max-age=0',
          'If-Modified-Since': ifModifiedSince,
        },
      },
    );
    if (response.statusCode == 304) {
      return;
    }
    await file.writeAsBytes(response.bodyBytes);
    if (cache) {
      final lastModified = response.headers['last-modified'];
      if (lastModified == null) {
        return;
      }
      if (_dateFormat.tryParse(lastModified) case final DateTime lastModified) {
        await file.setLastModified(lastModified);
      } else {
        io.stderr.writeln(
          'Failed to parse last-modified header: $lastModified.',
        );
      }
    }
  }
}
