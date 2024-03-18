import 'dart:convert';
import 'dart:io' as io;

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:http/http.dart' as http;
import 'package:jawa/src/cached_http_client.dart';
import 'package:jawa/src/swu_api.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:scrap/scrap.dart';
import 'package:stack_trace/stack_trace.dart';

void main(List<String> args) async {
  try {
    await _JawaRunner().run(args);
  } on UsageException catch (e) {
    io.stdout.writeln(e.usage);
  } catch (e, st) {
    io.stderr.writeln('An error occurred: $e');
    io.stderr.writeln(Trace.from(st).terse);
    io.exitCode = 1;
  }
}

final _shell = io.Platform.environment['JAWA_SHELL'] == 'true';

final _path = Uri.file(
  io.Platform.script.toFilePath(),
).resolve(p.join('..', '..', '..')).toFilePath();

final class _JawaRunner extends CommandRunner<void> {
  _JawaRunner() : super('jawa', 'A tool.') {
    addCommand(_Scavenge());
  }
}

final class _Scavenge extends Command<void> {
  @override
  String get name => 'scavenge';

  @override
  String get description => 'Scrapes the web for card data.';

  _Scavenge() {
    argParser
      ..addFlag(
        'cache',
        abbr: 'c',
        help: 'Whether to use a cache instead of fetching data, if available.',
        defaultsTo: _shell,
      )
      ..addOption(
        'output',
        abbr: 'o',
        help: 'The output directory for the artifacts.',
        defaultsTo: p.join(_path, 'data'),
      );
  }

  @override
  @protected
  ArgResults get argResults => super.argResults!;

  @override
  void run() async {
    final (cache, output) = (
      argResults['cache'] as bool,
      argResults['output'] as String,
    );

    var client = http.Client();
    if (cache) {
      final cacheDir = io.Directory(p.join(_path, '.cache', 'swu-api'));
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
          switch (data.type.name) {
            case 'Leader':
              card = LeaderCard(
                title: data.title,
                number: data.cardNumber,
                rarity: Rarity.fromName(data.rarity.name.toLowerCase()),
                aspects: Aspects.from(
                  data.aspects.map(
                    (a) => Aspect.fromName(a.name.toLowerCase()),
                  ),
                ),
                subTitle: data.subTitle!,
                cost: data.cost!,
                health: data.hp!,
                power: data.power!,
              );
            case 'Base':
              card = BaseCard(
                title: data.title,
                number: data.cardNumber,
                rarity: Rarity.fromName(data.rarity.name.toLowerCase()),
                aspects: Aspects.from(
                  data.aspects.map(
                    (a) => Aspect.fromName(a.name.toLowerCase()),
                  ),
                ),
                health: data.hp!,
              );
            case 'Unit':
              card = UnitCard(
                title: data.title,
                number: data.cardNumber,
                rarity: Rarity.fromName(data.rarity.name.toLowerCase()),
                aspects: Aspects.from(
                  data.aspects.map(
                    (a) => Aspect.fromName(a.name.toLowerCase()),
                  ),
                ),
                subTitle: data.subTitle,
                cost: data.cost!,
                health: data.hp!,
                power: data.power!,
              );
            case 'Upgrade':
              card = UpgradeCard(
                title: data.title,
                number: data.cardNumber,
                rarity: Rarity.fromName(data.rarity.name.toLowerCase()),
                aspects: Aspects.from(
                  data.aspects.map(
                    (a) => Aspect.fromName(a.name.toLowerCase()),
                  ),
                ),
                cost: data.cost!,
              );
            case 'Event':
              card = EventCard(
                title: data.title,
                number: data.cardNumber,
                rarity: Rarity.fromName(data.rarity.name.toLowerCase()),
                aspects: Aspects.from(
                  data.aspects.map(
                    (a) => Aspect.fromName(a.name.toLowerCase()),
                  ),
                ),
                cost: data.cost!,
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
        final file = io.File(p.join(outputDir.path, '${set.code}.json'));
        await file.writeAsString(const JsonEncoder.withIndent('  ').convert(
          set.build().toJson(),
        ));
      }
    } finally {
      client.close();
    }
  }
}

final class _ExpansionBuilder {
  final String name;
  final String code;
  final int count;
  final List<Card> cards;

  _ExpansionBuilder({
    required this.name,
    required this.code,
    required this.count,
  }) : cards = [];

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
