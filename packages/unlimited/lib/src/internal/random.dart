import 'dart:math';

import 'package:meta/meta.dart';

/// Returns the default random number generator to use across the library.
Random get defaultRandom => _defaultRandom;
var _defaultRandom = Random();

/// Resets the default random number generator to a new instance.
@visibleForTesting
void resetDefaultRandom([Random? random]) {
  _defaultRandom = random ?? Random();
}
