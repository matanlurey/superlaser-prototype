import 'dart:io' as io;

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:http/http.dart' as http;
import 'package:jawa/src/cached_http_client.dart';
import 'package:jawa/src/swu_api.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
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
    final (cache, _) = (
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
      await for (final data in api.fetchAllCards()) {
        io.stderr.writeln(
          'Fetched page ${data.pagination.page} of '
          '${data.pagination.pageCount}.',
        );
      }
    } finally {
      client.close();
    }
  }
}
