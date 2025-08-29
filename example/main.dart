import 'package:xxhash/xxhash.dart';
import 'dart:convert';

void main() {
  XXHash.setDynamicLibraryPath('../src/');

  var bytes = utf8.encode("foobar");

  var digest = xxh32.convert(bytes);

  print("Digest as bytes: ${digest.bytes}");
  print("Digest as hex string: $digest");
}
