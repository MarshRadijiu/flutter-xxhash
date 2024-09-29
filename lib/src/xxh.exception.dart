// Copyright (c) 2015, the Dart project authors.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A runtime exception thrown by the XXH bindings when native code fails.
///
/// The [message] property contains a human-readable description of the error
/// that occurred.
class XXHException implements Exception {
  String message;

  XXHException(this.message);
}
