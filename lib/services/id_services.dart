import 'dart:math';

/// Simple unique ID generator.
/// Swap with `uuid` package in production if needed.
class IdService {
  static final _random = Random.secure();

  static String generate() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    final randomPart = List.generate(
      8,
          (_) => _random.nextInt(36).toRadixString(36),
    ).join();
    return '$timestamp-$randomPart';
  }
}
