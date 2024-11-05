// Copyright (c) 2015, the Dart project authors.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../xxhash.dart';

typedef _Canonical<Canonical extends NativeType> = (
  Pointer<Canonical>,
  Array<UnsignedChar>
);

/// Base class for all XXHash.
///
/// Every hash is a converter that takes a list of integers and returns a single
/// digest. When used in chunked mode, it will only ever add one digest to the
/// inner [Sink].
abstract class XXHash<Hash, Canonical extends NativeType>
    extends Converter<List<int>, Digest> {
  const XXHash._();

  @override
  Digest convert(List<int> input) => _digest(_hash(input));

  Hash _hash(List<int> input) {
    final pointer = _pointer(input);
    final hash = _xxh(pointer, input.length);
    calloc.free(pointer);
    return hash;
  }

  Hash _xxh(Pointer<Void> pointer, int length);

  Digest _digest(Hash hash) {
    final (pointer, digest) = _canonicalFromHash(hash);
    final bytes = Uint8List.fromList(
      List.generate(
        _digestSize,
        (index) => digest[index],
      ),
    );

    calloc.free(pointer);
    return Digest(bytes);
  }

  int get _digestSize;

  _Canonical<Canonical> _canonicalFromHash(Hash hash);

  @override
  ByteConversionSink startChunkedConversion(Sink<Digest> sink);

  /// The current version number of the native xxhash library.
  static int get version => _bindings.XXH_versionNumber();

  /// The minimum size of a secret buffer.
  static const int secretSizeMin = XXH3_SECRET_SIZE_MIN;

  /// The default size of a secret buffer.
  static const int secretDefaultSize = XXH3_SECRET_DEFAULT_SIZE;

  /// The maximum size of a input to be considered "short".
  static const int maxSeededInputByte = XXH3_MIDSIZE_MAX;

  /// Set the path to the dynamic library in which the symbols for [XxhashBindings] can be found.
  ///
  /// [path] can be either absolute or relative to the current working directory.
  static void setDynamicLibraryPath(String path) {
    _dylibPath = path;
  }
}
