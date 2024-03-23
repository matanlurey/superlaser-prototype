/// Represents an opaque identifier, usually for uniquely identifying an object.
extension type const Id._(String _id) {
  /// Creates a new [Id] with a unique identifier.
  ///
  /// The identifier is generated by incrementing a counter.
  factory Id() {
    return Id._((_nextId++).toString());
  }

  /// Creates a new [Id] from the given string.
  ///
  /// The string must not be empty.
  factory Id.from(String id) {
    if (id.isEmpty) {
      throw ArgumentError.value(id, 'id', 'Must not be empty');
    }
    return Id._(id);
  }

  static var _nextId = 1000;
}