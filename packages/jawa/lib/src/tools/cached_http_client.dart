import 'dart:convert';
import 'dart:io' as io;

import 'package:crypto/crypto.dart' show md5;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

final class CachedHttpClient extends http.BaseClient {
  final io.Directory _cacheDir;
  final http.Client _innerClient;

  static Future<CachedHttpClient> using(
    io.Directory cacheDir,
    http.Client innerClient,
  ) async {
    await cacheDir.create(recursive: true);
    final client = CachedHttpClient._(cacheDir, innerClient);
    return client;
  }

  CachedHttpClient._(this._cacheDir, this._innerClient);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request.method != 'GET') {
      return _innerClient.send(request);
    }

    final accept = request.headers['accept'] ?? '';
    final isJson = accept.contains('application/json');
    final hash = md5.convert(request.url.toString().codeUnits).toString();
    final ext = isJson ? '.json' : '';
    final file = io.File(p.join(_cacheDir.path, '$hash$ext'));
    if (!await file.exists()) {
      final response = await _innerClient.send(request);
      await setCache(request.url, response);
    }

    final bytes = await file.readAsBytes();
    return http.StreamedResponse(
      Stream.value(bytes),
      200,
      contentLength: bytes.length,
      headers: {
        if (isJson) 'content-type': 'application/json',
      },
    );
  }

  Future<void> clearCache() async {
    await _cacheDir.delete(recursive: true);
    await _cacheDir.create();
  }

  Future<void> setCache(Uri uri, http.StreamedResponse response) async {
    final hash = md5.convert(uri.toString().codeUnits).toString();
    final type = response.headers['content-type'] ?? '';
    final ext = type.contains('application/json') ? '.json' : '';
    final file = io.File(p.join(_cacheDir.path, '$hash$ext'));

    // If it's JSON, pretty-print it.
    if (ext == '.json') {
      final json = await response.stream.bytesToString();
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(
          const JsonDecoder().convert(json),
        ),
      );
      return;
    }
    await file.writeAsBytes(await response.stream.toBytes());
  }
}
