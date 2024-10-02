// Copyright (c) 2015, the Dart project authors.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:xxhash/src/digest/digest.dart';
import 'package:xxhash/src/hash/hash.sink.dart';
import 'package:xxhash/src/xxh.exception.dart';
import 'package:xxhash/src/xxhash_bindings.dart';

import 'xxhash_bindings.g.dart';

part 'hash/hash.dart';
part 'xxh32/xxh32.dart';
part 'xxh64/xxh64.dart';
part 'xxh3/xxh3.dart';
part 'xxh3/xxh3_64.dart';
part 'xxh3/xxh3_128.dart';

const String _libName = 'xxhash';

/// The dynamic library in which the symbols for [XxhashBindings] can be found.
final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    try {
      return DynamicLibrary.open('$_libName.framework/$_libName');
    } catch (_) {
      return DynamicLibrary.open('$_libName.dylib');
    }
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    try {
      return DynamicLibrary.open('$_libName.dll');
    } catch (_) {
      try {
        return DynamicLibrary.open('lib${_libName}32.dll');
      } catch (_) {
        return DynamicLibrary.open('lib${_libName}64.dll');
      }
    }
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// The bindings to the native functions in [_dylib].
final XxhashBindingsExtended _bindings = XxhashBindingsExtended(_dylib);

/// An implementation of the [XXH32] hash function.
///
/// [XXH32.seed] can be used to change the hash's seed.
const xxh32 = XXH32._();

/// An implementation of the [XXH64] hash function.
///
/// [XXH64.seed] can be used to change the hash's seed.
const xxh64 = XXH64._();

/// An implementation of the [XXH3] 64 bits hash function.
///
/// [XXH3Bits64.seed] can be used to change the hash's seed for smaller inputs.
///
/// [XXH3Bits64.secret] can be used to change the hash's secret for larger inputs.
///
/// [XXH3Bits64.withSecretAndSeed] can be used to change the hash's secret and seed based on input length.
const xxh3_64 = XXH3Bits64._();

/// An implementation of the [XXH3] 128 bits hash function.
///
/// [XXH3Bits128.seed] can be used to change the hash's seed for smaller inputs.
///
/// [XXH3Bits128.secret] can be used to change the hash's secret for larger inputs.
///
/// [XXH3Bits128.withSecretAndSeed] can be used to change the hash's secret and seed based on input length.
const xxh3_128 = XXH3Bits128._();
