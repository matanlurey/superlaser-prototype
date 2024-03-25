import 'package:app/src/tools/persist.dart';
import 'package:app/ui.dart';
import 'package:flutter/material.dart';

void main() async {
  final baseImageUrl = Uri.https('try.superlaser.dev', 'images');
  runApp(
    CardImageProvider(
      resolve: (card, type) {
        final url = baseImageUrl.replace(
          pathSegments: [
            ...baseImageUrl.pathSegments,
            card.expansion,
            '${card.number.toString().padLeft(3, '0')}.${type.name}.png',
          ],
        );
        // TODO: Cache the image.
        return NetworkImage(url.toString());
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // TODO: Make this configurable/come from system settings.
        theme: ThemeData.dark(),
        home: HomeView(
          persistence: Persistence(),
        ),
      ),
    ),
  );
}
