import 'package:flutter/material.dart';
import 'package:unlimited/catalog/sor.dart' as sor;
import 'package:unlimited/engine.dart';

/// Crack a simulated booster pack.
final class CrackView extends StatefulWidget {
  /// Creates a new [CrackView].
  const CrackView({
    super.key,
  });

  @override
  State<CrackView> createState() => _CrackViewState();
}

final class _CrackViewState extends State<CrackView> {
  static final _generator = BoosterGenerator(sor.cards);

  BoosterPack? _pack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crack a Pack'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _pack = _generator.create();
              });
            },
          ),
        ],
      ),
      body: _pack == null
          ? Center(
              child: MaterialButton(
                onPressed: () {
                  setState(() {
                    _pack = _generator.create();
                  });
                },
                // Primary color.
                textTheme: ButtonTextTheme.primary,
                child: const Text('Crack a Pack'),
              ),
            )
          : ListView(
              children: [],
            ),
    );
  }
}
