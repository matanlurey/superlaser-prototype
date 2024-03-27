/// Whether assertions are enabled.
///
/// This properly is highly coorelated with being true in debug or development
/// modes of Dart and Flutter, and false in release or production modes, based
/// on the presence of `--enable-asserts` or `--no-enable-asserts` flags.
bool get assertionsEnabled {
  var enabled = false;
  assert(enabled = true, 'Always executed in debug mode.');
  return enabled;
}

/// Returns [value] if assertions are enabled, otherwise `null`.
T? debugOrNull<T>(T? value) => assertionsEnabled ? value : null;
