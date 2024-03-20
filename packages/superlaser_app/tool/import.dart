#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io' as io;

import 'package:args/args.dart';
import 'package:jsonut/jsonut.dart';
import 'package:path/path.dart' as p;
import 'package:scrap/scrap.dart' as scrap;
import 'package:superlaser_app/src/cards.dart';

/// Generates `assets/cards.json` based on the reference JSON files.
///
/// The format of the output JSON file is as follows:
/// ```jsonc
/// {
///   "sor": {
///     "name": "Spark of Rebellion",
///     "cards": {
///       /* card */
///       1: "Director Krennic",
///
///       /* variant */
///       269: 1,
///     }
///   }
/// }
/// ```
void main(List<String> args) {
  final projectRoot = io.Platform.script.resolve('../../../').toFilePath();

  final parser = ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Print usage information.',
      negatable: false,
    )
    ..addOption(
      'input',
      abbr: 'i',
      help: 'The path that contains reference JSON files.',
      defaultsTo: p.join(projectRoot, 'data'),
    )
    ..addOption(
      'output',
      abbr: 'o',
      help: 'The path to the output JSON file.',
      defaultsTo: p.join(
        projectRoot,
        'packages',
        'superlaser_app',
        'assets',
        'cards.json',
      ),
    );

  final result = parser.parse(args);
  if (result['help'] as bool) {
    io.stdout.writeln('Usage: tool/import.dart [options]');
    io.stdout.writeln(parser.usage);
    return;
  }

  // Find every JSON file in the input directory.
  final inputDir = io.Directory(result['input'] as String);
  final files = inputDir
      .listSync()
      .whereType<io.File>()
      .where((file) => p.extension(file.path) == '.json');

  // Create a database of cards from the reference JSON files.
  final database = Database();
  final outputFile = io.File(result['output'] as String);

  for (final file in files) {
    io.stderr.writeln('Processing ${file.path}...');

    final json = JsonObject.parse(file.readAsStringSync());
    final cards = scrap.Expansion.fromJson(json);

    database.addExpansion(cards.code, cards.name);

    for (final card in cards.cards) {
      database.addCard(cards.code, card.number, card.title);

      if (card.variants case final scrap.Variants v) {
        if (v.hyperspace case final scrap.Variant h) {
          database.addVariant(cards.code, h.number, card.number);
        }
        if (v.showcase case final scrap.Variant s) {
          database.addVariant(cards.code, s.number, card.number);
        }
      }
    }
  }

  // Write the database to the output JSON file.
  outputFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(database.toJson()),
  );
}
