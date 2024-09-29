// Copyright (c) 2015, the Dart project authors.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../xxhash.dart';

/// Implementation of XXH64 family.
class XXH64 extends XXHash<int, XXH64_canonical_t> {
  /// seed used to alter the hash's output predictably.
  final int seed;

  /// Creates a new instance of [XXH32] with the default [seed].
  const XXH64._()
      : seed = 0,
        super._();

  /// Creates a new instance of [XXH32] with the given [seed].
  const XXH64.seed(this.seed) : super._();

  @override
  int _xxh(Pointer<Void> pointer, int length) =>
      _bindings.XXH64(pointer, length, seed);

  @override
  int get _digestSize => 8;

  @override
  _Canonical<XXH64_canonical_t> _canonicalFromHash(int hash) {
    Pointer<XXH64_canonical_t> pointer = calloc<XXH64_canonical_t>();

    _bindings.XXH64_canonicalFromHash(pointer, hash);

    return (pointer, pointer.ref.digest);
  }

  @override
  ByteConversionSink startChunkedConversion(Sink<Digest> sink) =>
      ByteConversionSink.from(_XXH64Sink(sink, seed, _digest));
}

class _XXH64Sink extends XXHSink<XXH64_state_s, int> {
  final int seed;

  _XXH64Sink(super.sink, this.seed, super.digest);

  @override
  Pointer<XXH64_state_s> createState() => _bindings.XXH64_createState();

  @override
  int free(Pointer<XXH64_state_s> state) => _bindings.XXH64_freeState(state);

  @override
  int hash(Pointer<XXH64_state_s> state) => _bindings.XXH64_digest(state);

  @override
  int reset(Pointer<XXH64_state_s> state) => _bindings.XXH64_reset(state, seed);

  @override
  int update(Pointer<XXH64_state_s> state, Pointer<Void> data, int length) =>
      _bindings.XXH64_update(state, data, length);
}
