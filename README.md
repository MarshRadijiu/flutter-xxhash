A FFI plugin package that implements xxHash, inspired by [crypto](https://pub.dev/packages/crypto).

The following hashing algorithms are supported:

* XXH32
* XXH64
* XXH3 (XXH3-64, XXH3-128)

## Usage

### Digest on a single input

To hash a list of bytes, invoke the `convert` method on the
`xxh32`, `xxh64` or `xxh3` objects.

```dart
import 'package:xxhash/xxhash.dart';
import 'dart:convert'; // for the utf8.encode method

void main() {
  var bytes = utf8.encode("foobar"); // data being hashed

  var digest = xxh32.convert(bytes);

  print("Digest as bytes: ${digest.bytes}");
  print("Digest as hex string: $digest");
}
```

### Digest on chunked input

If the input data is not available as a _single_ list of bytes, or needs to be chunked, use
the chunked conversion approach.

Invoke the `startChunkedConversion` method
to create a sink for the input data. On the sink, invoke the `add`
method for each chunk of input data, and invoke the `close` method
when all the chunks have been added. The digest can then be retrieved
from the `Sink<Digest>` used to create the input data sink.

```dart
import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:xxhash/xxhash.dart';

void main() {
  var firstChunk = utf8.encode("foo");
  var secondChunk = utf8.encode("bar");

  var output = AccumulatorSink<Digest>();
  var input = xxh32.startChunkedConversion(output);
  input.add(firstChunk);
  input.add(secondChunk); // call `add` for every chunk of input data
  input.close();
  var digest = output.events.single;

  print("Digest as bytes: ${digest.bytes}");
  print("Digest as hex string: $digest");
}
```

The above example uses the `AccumulatorSink` class that comes with the
_convert_ package. It is capable of accumulating multiple events, but
in this usage only a single `Digest` is added to it when the data sink's
`close` method is invoked.

## Testing, or Dart only projects

The shared dynamic library is not available when using dart alone without Flutter or during tests. For these circumstances, you can download the following pre-compiled dynamic libraries from [Latest Release](https://github.com/MarshRadijiu/flutter-xxhash/releases/latest).

### Linux

Download `libxxhash.so` and add the folder path where the dynamic library is stored to `LD_LIBRARY_PATH` environment variable:

```bash
export LD_LIBRARY_PATH=<path/to/folder>:$LD_LIBRARY_PATH
```

This command sets your `LD_LIBRARY_PATH` variable for the current terminal window only. 

To permanently add `LD_LIBRARY_PATH` to your path, you can add it to the `/etc/environment`.

### Windows

Download `libxxhash32.dll`, or `libxxhash64.dll`, based on your windows architecture and add the folder path where the dynamic library is stored to the `PATH` environment:

```bash
setx PATH <path/to/folder>
```


### If Environment Variable is not available

`xxhash` can link the shared library using `XXHASH.setDynamicLibraryPath`. 

The given folder path can be either absolute or relative to the current working directory.

```dart
XXHash.setDynamicLibraryPath("<path/to/folder>");
```