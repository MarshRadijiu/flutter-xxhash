// Copyright (c) 2015, the Dart project authors.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:xxhash/src/xxhash_bindings.g.dart';
import 'package:xxhash/src/digest/digest.dart';
import 'package:xxhash/src/xxh.exception.dart';

/// A base class for [Sink] implementations for hash algorithms.
abstract class XXHSink<State extends Opaque, Hash> implements Sink<List<int>> {
  late Pointer<State> state;
  final Digest Function(Hash hash) _digest;

  /// The inner sink that this should forward to.
  final Sink<Digest> _sink;

  /// Whether [close] has been called.
  bool _isClosed = false;

  XXHSink(this._sink, this._digest) {
    state = createState();
    if (reset(state) == XXH_errorcode.XXH_ERROR) {
      throw XXHException('Failed to reset hash state');
    }
  }

  Pointer<State> createState();

  int reset(Pointer<State> state);

  int update(Pointer<State> state, Pointer<Void> data, int length);

  Hash hash(Pointer<State> state);

  int free(Pointer<State> state);

  @override
  void add(List<int> data) {
    if (_isClosed) throw StateError('Hash.add() called after close().');
    _updateHash(data);
  }

  void _updateHash(List<int> chunk) {
    final Pointer<Uint8> pointer = calloc<Uint8>(chunk.length);

    for (int i = 0; i < chunk.length; i++) {
      pointer[i] = chunk[i];
    }

    if (update(state, pointer.cast(), chunk.length) ==
        XXH_errorcode.XXH_ERROR) {
      throw XXHException('Failed to update hash state');
    }

    calloc.free(pointer);
  }

  @override
  void close() {
    if (_isClosed) return;
    _isClosed = true;

    _sink.add(_digest(hash(state)));
    _sink.close();
    this.free(state);
  }
}
