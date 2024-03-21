import 'dart:io' as io;

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:jsonut/jsonut.dart';
import 'package:path/path.dart' as p;
import 'package:scrap/scrap.dart' as scrap;

/// Provides code generation from collected data into Dart code.
final class Retrofit extends Command<void> {
  /// Creates a new Retrofit command.
  Retrofit({
    required String projectRoot,
  }) {
    argParser
      ..addOption(
        'input',
        abbr: 'i',
        help: 'The input file(s) to read from. Supports glob patterns.',
        valueHelp: 'path/to/foo.json',
        defaultsTo: p.join(
          projectRoot,
          'data',
          '*.json',
        ),
      )
      ..addOption(
        'output',
        abbr: 'o',
        help: 'Where to write the generated code.',
        valueHelp: 'path/to/dir',
        defaultsTo: p.join(
          projectRoot,
          'packages',
          'unlimited',
          'lib',
          'catalog',
        ),
      );
  }

  @override
  String get name => 'retrofit';

  @override
  String get description => 'Generates Dart code from collected data.';

  @override
  ArgResults get argResults => super.argResults!;

  @override
  Future<void> run() async {
    final input = Glob(argResults['input'] as String);
    final output = io.Directory(argResults['output'] as String);
    await output.create(recursive: true);

    await for (final file in input.list()) {
      if (file case final io.File file) {
        final used = <String>{};
        final idCache = <(String, Type), String>{};

        final json = JsonObject.parse(await file.readAsString());
        final data = scrap.Expansion.fromJson(json);
        final code = StringBuffer()
          ..writeln('/// Card data for _${data.name}_.')
          ..writeln('///')
          ..writeln(
            '/// It is recommended to import this library with a prefix:',
          )
          ..writeln('/// ```dart')
          ..writeln(
            "/// import 'package:unlimited/catalog/${data.code}.dart' as ${data.code};",
          )
          ..writeln('/// ```')
          ..writeln('///')
          ..writeln(
            '/// See [expansion] for set information and [cards] for all cards.',
          )
          ..writeln('library;')
          ..writeln()
          ..writeln("import 'package:unlimited/core.dart';")
          ..writeln()
          ..writeln('// GENERATED FILE - DO NOT EDIT')
          ..writeln('// Generated from ${file.path}')
          ..writeln(
            '// To regenerate, run `./bin/jawa retrofit -i data/${p.basename(file.path)}`',
          )
          ..writeln();

        // Write out set information.
        // ignore: cascade_invocations
        code
          ..writeln('/// _${data.name}_ set.')
          ..writeln(
            'final expansion = Expansion.${_nameToIdentifier(data.name)};',
          )
          ..writeln();

        // For each card, generate a top-level field.
        for (final card in data.cards) {
          var identifier = _nameToIdentifier(card.title);
          if (!used.add(identifier) && card is scrap.ArenaCard) {
            // Add the subtitle to the identifier to make it unique.
            identifier = _nameToIdentifier('${card.title}_${card.subTitle!}');
            used.add(identifier);
          }

          // TODO: Consider breaking this whole thing into an intermediate step
          // (i.e. with proper data structures) so that hacks like this aren't
          // needed.
          idCache[(card.title, card.runtimeType)] = identifier;

          code
            ..writeln(
              '/// ${data.code.toUpperCase()} '
              '${card.number.toString().padLeft(3, '0')}: '
              '**${card.title}**${card is scrap.ArenaCard && card.subTitle != null ? ' - ${card.subTitle}' : ''}.',
            )
            ..writeln('///')
            ..writeln(
              '/// ![](${card.art.front.url})',
            )
            ..writeln(
              'final $identifier = ${_cardToConstructor(identifier, card)};',
            )
            ..writeln();
        }

        // Write out a list of all cards.
        // ignore: cascade_invocations
        code
          ..writeln('/// All cards in _${data.name}_.')
          ..writeln('///')
          ..writeln(
            '/// Cards are listed by [Card.number] and at at `index-1`:',
          )
          ..writeln('/// ```dart')
          ..writeln('/// final sor1 = cards[0];')
          ..writeln('/// ```')
          ..writeln(
            'final cards = CatalogExpansion(${_createList([
                  ...data.cards.map(
                    (c) => _invokeConstructor(
                      'CanonicalCard',
                      comment: '$c',
                      {
                        'card': idCache[(c.title, c.runtimeType)]!,
                      },
                      indent: '  ',
                    ),
                  ),
                  ..._collectVariants(data.cards, count: data.count),
                ])});',
          );

        await io.File(
          p.join(output.path, '${data.code}.dart'),
        ).writeAsString(code.toString());
      }
    }
  }

  static Iterable<String> _collectVariants(
    Iterable<scrap.Card> cards, {
    required int count,
  }) {
    // Create a mapping of all variants to their cards.
    final variantMap = <scrap.Variant, scrap.Card>{};
    final variantShowcase = <scrap.Variant>{};
    for (final card in cards) {
      if (card.variants case final scrap.Variants v) {
        if (v.hyperspace case final scrap.Variant h) {
          variantMap[h] = card;
        }
        if (v.showcase case final scrap.Variant s) {
          variantMap[s] = card;
          variantShowcase.add(s);
        }
      }
    }

    // Create a list of all variant cards.
    final variants = [
      for (final card in cards)
        if (card.variants case final scrap.Variants v) ...[
          if (v.hyperspace case final scrap.Variant h) h,
          if (v.showcase case final scrap.Variant s) s,
        ],
    ];

    // Sort them by number.
    // ignore: cascade_invocations
    variants.sort((a, b) => a.number.compareTo(b.number));

    // Emit constructor calls.
    return variants.where((v) {
      // TODO: Support promotional variants that have the same number!
      return v.number > count;
    }).map((v) {
      return _invokeConstructor(
        'VariantCard',
        {
          'variantNumber': v.number.toString(),
          'card': _nameToIdentifier(variantMap[v]!.title),
          'type': ''
              'VariantType.'
              '${variantShowcase.contains(v) ? 'showcase' : 'hyperspace'}',
        },
        indent: '  ',
      );
    });
  }

  static String _invokeConstructor(
    String name,
    Map<String, String> fields, {
    String indent = '',
    String? comment,
  }) {
    final buffer = StringBuffer();
    if (comment != null) {
      buffer
        ..writeln('// $comment')
        ..write(indent);
    }
    buffer
      ..writeln('$name(')
      ..writeAll(
        fields.entries.map((e) => '$indent  ${e.key}: ${e.value},\n'),
      )
      ..write('$indent)');
    return buffer.toString();
  }

  static String _createList(
    Iterable<String> elements, {
    String indent = '',
  }) {
    final buffer = StringBuffer()
      ..writeln('[')
      ..writeAll(
        elements.map((e) => '$indent  $e,\n'),
      )
      ..write('$indent]');
    return buffer.toString();
  }

  static String _cardToConstructor(String identifier, scrap.Card card) {
    final base = <String, String>{
      'expansion': 'expansion',
      'number': card.number.toString(),
      'name': _safeString(card.title),
    };
    return switch (card) {
      final scrap.LeaderCard c => _invokeConstructor(
          'LeaderCard',
          {
            ...base,
            'unique': card.unique.toString(),
            'subTitle': _safeString(c.subTitle),
            'unit': _invokeConstructor(
              'LeaderUnitCard',
              {
                ...base,
                'unique': card.unique.toString(),
                'subTitle': _safeString(c.subTitle),
                'traits': _createList(
                  c.traits.map((t) => 'Trait.${_nameToIdentifier(t)}'),
                  indent: '    ',
                ),
                'cost': c.cost.toString(),
                'power': c.power.toString(),
                'health': c.health.toString(),
              },
              indent: '  ',
            ),
          },
        ),
      final scrap.BaseCard c => _invokeConstructor(
          'BaseCard',
          {
            ...base,
            'health': c.health.toString(),
          },
        ),
      final scrap.UnitCard c => _invokeConstructor(
          'UnitCard',
          {
            ...base,
            'subTitle': _safeString(c.subTitle),
            'unique': card.unique.toString(),
            'traits': _createList(
              c.traits.map((t) => 'Trait.${_nameToIdentifier(t)}'),
              indent: '  ',
            ),
            'cost': c.cost.toString(),
            'power': c.power.toString(),
            'health': c.health.toString(),
            'arena': 'ArenaType.${_nameToIdentifier(c.arena.name)}',
          },
        ),
      final scrap.EventCard c => _invokeConstructor(
          'EventCard',
          {
            ...base,
            'unique': card.unique.toString(),
            'traits': _createList(
              c.traits.map((t) => 'Trait.${_nameToIdentifier(t)}'),
              indent: '  ',
            ),
            'cost': c.cost.toString(),
          },
        ),
      final scrap.UpgradeCard c => _invokeConstructor(
          'UpgradeCard',
          {
            ...base,
            'unique': card.unique.toString(),
            'traits': _createList(
              c.traits.map((t) => 'Trait.${_nameToIdentifier(t)}'),
              indent: '  ',
            ),
            'cost': c.cost.toString(),
          },
        ),
    };
  }

  /// Wraps a string in quotes as a valid Dart string.
  static String _safeString(String? string) {
    // If it's null, return null.
    if (string == null) {
      return 'null';
    }

    // If it has an apostrophe, use double quotes.
    if (string.contains("'")) {
      return '"$string"';
    }
    return "'$string'";
  }

  /// Converts a name to a valid and idiomatic Dart identifier.
  static String _nameToIdentifier(String name) {
    // Remove apostrophes.
    name = name.replaceAll(RegExp("'"), '');

    // If the name starts with a number, add a $ to the beginning.
    if (RegExp('^[0-9]').hasMatch(name)) {
      name = '\$$name';
    }

    // TODO: Replace accented characters with their non-accented equivalents.
    // For example Chirrut Îmwe -> Chirrut Imwe.

    // Replace all non-alphanumeric characters with underscores,
    var underscored = name
        .replaceAll(RegExp('[^a-zA-Z0-9]'), '_')
        .replaceAll(RegExp('^[0-9]'), r'_$');

    // Remove all duplicate underscores, and leading/trailing underscores.
    underscored = underscored
        .toLowerCase()
        .replaceAll(RegExp('_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');

    // TODO: Redo this function to avoid this hack.
    // Re-add a $ if the name starts with a number.
    if (RegExp('^[0-9]').hasMatch(underscored)) {
      underscored = '\$$underscored';
    }

    if (underscored.isEmpty) {
      throw FormatException('Invalid identifier: $name');
    }

    // Make it camelCase.
    return underscored.splitMapJoin(
      RegExp(r'_(\w)'),
      onMatch: (m) => m.group(1)!.toUpperCase(),
      onNonMatch: (s) => s,
    );
  }
}
