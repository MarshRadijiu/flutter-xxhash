// Copyright (c) 2015, the Dart project authors.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:typed_data';

/// A message digest as computed by any XXHash.
class Digest {
  /// The message digest as an array of bytes.
  final Uint8List bytes;

  const Digest(this.bytes);

  /// Returns whether this is equal to another digest.
  ///
  /// This should be used instead of manual comparisons to avoid leaking
  /// information via timing.
  @override
  bool operator ==(Object other) {
    if (other is Digest) {
      final a = bytes;
      final b = other.bytes;
      final n = a.length;
      if (n != b.length) {
        return false;
      }
      var mismatch = 0;
      for (var i = 0; i < n; i++) {
        mismatch |= a[i] ^ b[i];
      }
      return mismatch == 0;
    }
    return false;
  }

  @override
  int get hashCode => Object.hashAll(bytes);

  /// The message digest as a string of hexadecimal digits.
  @override
  String toString() =>
      bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}
