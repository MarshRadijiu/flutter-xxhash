// Copyright (c) 2015, the Dart project authors.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../xxhash.dart';

/// Implementation of XXH32 family.
class XXH32 extends XXHash<int, XXH32_canonical_t> {
  /// seed used to alter the hash's output predictably.
  final int seed;

  /// Creates a new instance of [XXH32] with the default [seed].
  const XXH32._()
      : seed = 0,
        super._();

  /// Creates a new instance of [XXH32] with the given [seed].
  const XXH32.seed(this.seed) : super._();

  @override
  int _xxh(Pointer<Void> pointer, int length) =>
      _bindings.XXH32(pointer, length, seed);

  @override
  int get _digestSize => 4;

  @override
  _Canonical<XXH32_canonical_t> _canonicalFromHash(int hash) {
    Pointer<XXH32_canonical_t> pointer = calloc<XXH32_canonical_t>();

    _bindings.XXH32_canonicalFromHash(pointer, hash);

    return (pointer, pointer.ref.digest);
  }

  @override
  ByteConversionSink startChunkedConversion(Sink<Digest> sink) =>
      ByteConversionSink.from(_XXH32Sink(sink, seed, _digest));
}

class _XXH32Sink extends XXHSink<XXH32_state_s, int> {
  final int seed;

  _XXH32Sink(super.sink, this.seed, super.digest);

  @override
  Pointer<XXH32_state_s> createState() => _bindings.XXH32_createState();

  @override
  int free(Pointer<XXH32_state_s> state) => _bindings.XXH32_freeState(state);

  @override
  int hash(Pointer<XXH32_state_s> state) => _bindings.XXH32_digest(state);

  @override
  int reset(Pointer<XXH32_state_s> state) => _bindings.XXH32_reset(state, seed);

  @override
  int update(Pointer<XXH32_state_s> state, Pointer<Void> data, int length) =>
      _bindings.XXH32_update(state, data, length);
}
