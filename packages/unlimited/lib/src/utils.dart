/// A collection of utility functions on [String].
extension StringExtension on String {
  /// Returns the receiver with the first character capitalized.
  String capitalize() {
    return isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : this;
  }
}
