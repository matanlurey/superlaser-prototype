export 'src/ui/views/browse.dart';
export 'src/ui/views/home.dart';
export 'src/ui/widgets/card_image.dart';

/// String utilities.
extension Strings on String {
  /// Capitalizes the first letter of the string.
  String capitalize() {
    if (isEmpty) {
      return this;
    }
    return this[0].toUpperCase() + substring(1);
  }
}
