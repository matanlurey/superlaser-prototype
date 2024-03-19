import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:jawa/src/scavenge.dart';
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
    addCommand(Scavenge(
      interactive: _shell,
      projectRoot: _path,
    ));
  }
}
