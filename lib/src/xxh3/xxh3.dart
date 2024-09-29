// Copyright (c) 2015, the Dart project authors.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../xxhash.dart';

/// Base class for XXH3 family.
///
/// It also provide the secret derivation functions.
abstract class XXH3<Hash, Canonical extends NativeType>
    extends XXHash<Hash, Canonical> {
  const XXH3._() : super._();

  /// Derive a high-entropy secret from any user-defined content, named seed.
  ///
  /// [seed]        A user-defined content.
  /// [length]      Size of secret, in bytes. Must be >= [XXHash.secretSizeMin].
  ///
  /// The generated secret can be used in combination with `XXH3.secret()` variants.
  /// The `secret()` variants are useful to provide a higher level of protection
  /// than 64-bit seed, as it becomes much more difficult for an external actor to
  /// guess how to impact the calculation logic.
  ///
  /// The function accepts as input a custom seed of any length and any content,
  /// and derives from it a high-entropy secret of length [length] into a new secret.
  ///
  /// The generated secret can then be used with any `secret()` variant.
  /// The functions [XXH3Bits128.secret] and [XXH3Bits64.secret],
  /// are part of this list. They all accept a `secret` parameter
  /// which must be large enough for implementation reasons (>= [XXHash.secretSizeMin])
  /// _and_ feature very high entropy (consist of random-looking bytes).
  /// These conditions can be a high bar to meet, so [XXH3.generateSecret] can
  /// be employed to ensure proper quality.
  ///
  /// [seed] can be anything. It can have any size, even small ones,
  /// and its content can be anything, even "poor entropy" sources such as a bunch
  /// of zeroes. The resulting `secret` will nonetheless provide all required qualities.
  static Uint8List generateSecret(Uint8List seed,
      [int length = XXHash.secretDefaultSize]) {
    assert(length >= XXHash.secretSizeMin);
    final Pointer<Uint8> pointer = calloc<Uint8>(length);

    final Pointer<Uint8> seedPointer = calloc<Uint8>(seed.length);

    for (int i = 0; i < seed.length; i++) {
      seedPointer[i] = seed[i];
    }

    if (_bindings.XXH3_generateSecret(
          pointer.cast(),
          length,
          seedPointer.cast(),
          seed.length,
        ) ==
        XXH_errorcode.XXH_ERROR) {
      throw XXHException('Impossible to generate secret.');
    }

    final secret = pointer.asTypedList(length);
    calloc.free(pointer);
    return secret;
  }

  /// Generate the same secret as the `XXH3.seeded()` variants.
  ///
  /// [length] Size of secret, in bytes. Must be >= [XXHash.secretSizeMin].
  /// [seed]   The 64-bit seed to alter the hash result predictably.
  ///
  /// The generated secret can be used in combination with
  /// `XXH3.seeded()` and `XXH3.withSecretAndSeed()` variants.
  ///
  /// Example:
  /// ```dart
  /// final seed = Random().nextInt(2 ^ 64);
  ///
  /// // Slow, seeds each time
  /// XXH3Bits64.seed(seed).convert(bytes);
  ///
  /// // Fast, caches the seeded secret for future uses.
  /// final secret = XXH3.generateSecretFromSeed(seed);
  /// XXH3Bits64.secret(secret).convert(bytes);
  /// ```
  static Uint8List generateSecretFromSeed(int seed,
      [int length = XXHash.secretDefaultSize]) {
    assert(length >= XXHash.secretSizeMin);

    final Pointer<Uint8> pointer = calloc<Uint8>(length);

    _bindings.XXH3_generateSecret_fromSeed(pointer.cast(), seed);

    final secret = pointer.asTypedList(length);
    calloc.free(pointer);
    return secret;
  }
}

mixin _XXH3Seeded<Hash, Canonical extends NativeType> {
  late final int _seed;

  /// seed used to alter the hash's output predictably.
  int get seed => _seed;

  set seed(int seed) {
    _seed = seed;
  }
}

mixin _XXH3Secret<Hash, Canonical extends NativeType> {
  late final Uint8List _secret;

  /// secret used to alter the hash's output predictably.
  Uint8List get secret => _secret;

  set secret(Uint8List secret) {
    assert(secret.length >= XXHash.secretSizeMin);
    _secret = secret;
  }

  Pointer<Void> _prepareSecret(List<int> secret) {
    final Pointer<Uint8> pointer = calloc<Uint8>(secret.length);

    for (int i = 0; i < secret.length; i++) {
      pointer[i] = secret[i];
    }

    return pointer.cast();
  }
}

abstract class _XXH3Sink<Hash> extends XXHSink<XXH3_state_t, Hash> {
  _XXH3Sink(super.sink, super.digest);

  @override
  Pointer<XXH3_state_t> createState() => _bindings.XXH3_createState();

  @override
  int free(Pointer<XXH3_state_t> state) => _bindings.XXH3_freeState(state);
}
