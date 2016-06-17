// Copyright (c) 2016, Open DICOMweb Project. All rights reserved.
// Use of this source code is governed by the open source license
// that can be found in the LICENSE file.
// Author: Jim Philbin <jfphilbin@gmail.edu>
// See the AUTHORS file for other contributors.
library odw.sdk.utilities.bytebuf.bytebuf_base;

import 'dart:typed_data';

import 'utils.dart';

class ByteBuf {
  /// The Endianness can be set before using
  Endianness endianness = Endianness.LITTLE_ENDIAN;

  /// The underlying [ByteBuffer].
  final ByteBuffer _buffer;

  /// A [Uint8List] view of [buffer].
  final Uint8List _bytes;

  /// A [ByteData] view of [buffer].
  final ByteData _bd;

  /// The index at which the [buffer] [slice] starts.
  final int _start;

  /// The index of the last byte + 1 of the [buffer] [slice];
  final int _end;

  /// The current read position in [this].
  int _readIndex;

  /// The current write position in [this].
  int _writeIndex;

/*
  static Uint8List _getEmptyBuffer(int length) {
    if ((length >= 0)) throw "Invalid Length: $length";
    return new Uint8List(length);
  }
*/
  factory ByteBuf([int length = 1024]) {
    if (length < 0) throw new ArgumentError('Invalid Length: $length');
    var bytes = new Uint8List(length);
    return new ByteBuf._(bytes, 0, length);
  }

  /// Constructs a [new] [ByteArray] of [length]. The default length is 1024.
  ByteBuf._(Uint8List bytes, int offset, length)
      : _buffer = bytes.buffer,
        _bytes = bytes,
        _bd = bytes.buffer.asByteData(offset, length),
        _start = offset,
        _end = offset + length;


  /// Returns a [new] [ByteBuf] with from [start] to [end].
  ByteBuf slice([start = 0, int end]) {
    checkView(_buffer, start, end);
    return new ByteBuf._(_bytes, start, end);
  }

  ByteBuf sublist(int start, [int end]) {
    checkSublist(_buffer, start, end);
    return new ByteBuf._(_bytes, start, end - start);
  }

  int operator [](int i)=> _bytes[i];

  void operator []=(int i, int val) {
    _bytes[i] = val;
  }

  int get readIndex => _readIndex;

  set readIndex(int readIndex) {
    if (readIndex < 0 || readIndex > writeIndex) {
      throw new RangeError(
          "readerIndex: $_readIndex (expected: 0 <= readerIndex <= writerIndex($_writeIndex))");
    }
    _readIndex = readIndex;
    //return this;
  }

  int get writeIndex => _writeIndex;

  set writeIndex(int writeIndex) {
    if (_writeIndex < _readIndex || _writeIndex > lengthInBytes) {
      throw new RangeError(
          "writerIndex: $_writeIndex (expected: readerIndex($_readIndex) "
              "<= writerIndex <= capacity($lengthInBytes)");
    }
    _writeIndex = writeIndex;
    //return this;
  }
  int get lengthInBytes => _end - _start;

  int get readCapacity => _writeIndex - _readIndex;

  int get writeCapacity => _end - _writeIndex;

  bool get isEmpty => _readIndex >= _end;

  bool get isNotEmpty => !isEmpty;

  int seek(int n) {
    checkRange(_readIndex, n, 1, "seek");
    return _readIndex += n;
  }

  int getLimit(int lengthInBytes) {
    int localLimit = _readIndex + lengthInBytes;
    if (localLimit > _end) throw "length $lengthInBytes too long";
    return localLimit;
  }

  int checkReadIndex(int readIndex) {
    if ((readIndex < _start) || (readIndex > _writeIndex))
      throw new RangeError( "readIndex $readIndex out of range (_start=$_start, _end=$_end");
    return _readIndex - readIndex;
  }

  int checkWriteIndex(int writeIndex) {
    if ((writeIndex < _readIndex) || (writeIndex > _end))
      throw new RangeError( "writeIndex $writeIndex out of range (_start=$_start, _end=$_end");
    return _readIndex - writeIndex;
  }

  //Flush:? not used
  //TODO add to Warnings
  int checkLimit(int limit) => (limit >= _end) ? _end : limit;

  void checkRange(int offset, int unitLength, int lengthInBytes, String caller) {
    if ((lengthInBytes ~/ unitLength) != 0)
      throw '$caller: Invalid Length=$lengthInBytes for UnitLength=$unitLength';
    int index = offset + (unitLength * lengthInBytes);
    if (index < _start) {
      throw '$caller: _readIndex cannot be less than 0';
    }
    if (index > _end) {
      throw '$caller: attempt to read past end of buffer';
    }
  }

}