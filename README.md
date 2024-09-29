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