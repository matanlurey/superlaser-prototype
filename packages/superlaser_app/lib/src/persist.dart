import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_file_saver/flutter_file_saver.dart';

/// Defines a platform-agnostic interface for persisting text to/from disk.
abstract final class Persistence {
  factory Persistence() = _Persistence;

  /// Imports a file from disk and returns its contents as a string.
  ///
  /// [allowedExtensions] is a list of file extensions that the user is allowed
  /// to select, if the platform supports filtering by file type. If omitted,
  /// the user may select any file type.
  ///
  /// Optionally, provide an [encoding] to use when reading the file, which
  /// defaults to UTF-8.
  ///
  /// Returns the contents of the file, or `null` if the user cancels.
  Future<String?> import({
    Iterable<String>? allowedExtensions,
    Encoding encoding = utf8,
  });

  /// Exports the given [text] to a file on disk.
  ///
  /// [fileName] is used as the default file name on supported devices.
  ///
  /// Returns an identifier for the file that was created, which on some
  /// devices may be a file path, and others may just be a unique identifier
  /// without much semantic value.
  ///
  /// If the user cancels, returns `null`.
  Future<String?> export(
    String text, {
    required String fileName,
  });
}

/// Default implementation that uses the platform's file picker.
final class _Persistence implements Persistence {
  @override
  Future<String?> import({
    Iterable<String>? allowedExtensions,
    Encoding encoding = utf8,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions?.toList(),
    );
    if (result == null || result.files.isEmpty) {
      return null;
    }
    final file = result.files.single;

    // Because this API is insane.
    final Uint8List data;
    if (file.bytes case final Uint8List bytes) {
      data = bytes;
    } else if (file.path case final String path) {
      data = await File(path).readAsBytes();
    } else {
      throw UnsupportedError('Unexpected file type: $file');
    }

    return encoding.decode(data);
  }

  final _saver = FlutterFileSaver();

  @override
  Future<String?> export(
    String text, {
    required String fileName,
  }) async {
    final result = await _saver.writeFileAsString(
      fileName: fileName,
      data: text,
    );
    return result;
  }
}
