import 'package:checks/context.dart';
export 'package:checks/checks.dart';
export 'package:test/test.dart';

extension MoreChecks<T> on Subject<T> {
  void equivalent(T other) {
    context.expect(() => const ['is equivalent to'], (actual) {
      if (actual != other) {
        return Rejection(which: const ['are not equal']);
      }
      if (actual.hashCode != other.hashCode) {
        return Rejection(which: const ['have different hash codes']);
      }
      return null;
    });
  }
}
