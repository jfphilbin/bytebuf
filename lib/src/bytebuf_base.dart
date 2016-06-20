// Copyright (c) 2016, Open DICOMweb Project. All rights reserved.
// Use of this source code is governed by the open source license
// that can be found in the LICENSE file.
// Author: Jim Philbin <jfphilbin@gmail.edu>
// See the AUTHORS file for other contributors.
library odw.sdk.utilities.bytebuf.bytebuf_base;

//import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

// TODO:
//  * Finish documentation
//  * Make buffers Unmodifiable
//  * Make buffer pools, both heap and non-heap and use check accessable.
//  * Make buffers growable
//  * Make a LoggingByteBuf
//  * create a big_endian_bytebuf.
//  * Can the Argument Errors and RangeErrors be merged
//  * reorganize:
//    ** ByteBufBase contains global static, general constructors and private fields and getters
//    ** ByteBufReader extends Base with Read constructors, methods and readOnly getter...
//    ** ByteBuf extends Reader with read and write constructors, methods...


/// A Byte Buffer implementation based on Netty's ByteBuf.
///
/// A [ByteBufBase] uses an underlying [Uint8List] to contain byte data,
/// where a "byte" is an unsigned 8-bit integer.  The "capacity" of the
/// [ByteBufBase] is always equal to the [length] of the underlying [Uint8List].
//TODO: finish description

const _MB = 1024 * 1024;
const _GB = 1024 * 1024 * 1024;

/// A skeletal implementation of a buffer.

abstract class ByteBufBase {
  static const defaultLengthInBytes = 1024;
  static const defaultMaxCapacity = 1 * _MB;
  static const maxMaxCapacity = 2 * _GB;
  static const endianness = Endianness.LITTLE_ENDIAN;

  Uint8List _bytes;
  ByteData _bd;
  int _readIndex;
  int _writeIndex;

  //*** Constructors ***

  /// Creates a new [ByteBufBase] of [maxCapacity], where
  ///  [readIndex] = [writeIndex] = 0.
  factory ByteBufBase([int lengthInBytes = defaultLengthInBytes]) {
    if (lengthInBytes == null)
      lengthInBytes = defaultLengthInBytes;
    if ((lengthInBytes < 0) || (lengthInBytes > maxMaxCapacity))
      throw new ArgumentError("lengthInBytes: $lengthInBytes "
          "(expected: 0 <= lengthInBytes <= maxCapacity($maxMaxCapacity)");
    return new ByteBufBase._(new Uint8List(lengthInBytes), 0, 0, lengthInBytes);
  }

  /// Creates a new readable [ByteBufBase] from the [Uint8List] [bytes].
  factory ByteBufBase.fromByteBuf(ByteBufBase buf, [int offset = 0, int length]) {
    length = (length == null) ? buf._bytes.length : length;
    if ((length < 0) || ((offset < 0) || ((buf._bytes.length - offset) < length)))
      throw new ArgumentError('Invalid offset($offset) or '
          'length($length) for ${buf._bytes}bytes(length = ${buf._bytes.lengthInBytes}');
    return new ByteBufBase._(buf._bytes, offset, length, length);
  }

  /// Creates a new readable [ByteBufBase] from the [Uint8List] [bytes].
  factory ByteBufBase.fromUint8List(Uint8List bytes, [int offset = 0, int length]) {
    length = (length == null) ? bytes.length : length;
    if ((length < 0) || ((offset < 0) || ((bytes.length - offset) < length)))
      throw new ArgumentError('Invalid offset($offset) or '
          'length($length) for $bytes(length = ${bytes.lengthInBytes}');
    return new ByteBufBase._(bytes, offset, length, length);
  }

  /// Creates a [Uint8List] with the same length as the elements in [list],
  /// and copies over the elements.  Values are truncated to fit in the list
  /// when they are copied, the same way storing values truncates them.
  factory ByteBufBase.fromList(List<int> list) =>
      new ByteBufBase._(new Uint8List.fromList(list), 0, list.length, list.length);

  /// Internal Constructor: Returns a [ByteBufBase] slice from [bytes].
  ByteBufBase._(Uint8List bytes, int readIndex, int writeIndex, int length)
      : _bytes = bytes.buffer.asUint8List(readIndex, length),
        _bd = bytes.buffer.asByteData(readIndex, length),
        _readIndex = readIndex,
        _writeIndex = writeIndex;

  /// Creates a new [ByteBufBase] that is a view of [this].  The underlying
  /// [Uint8List] is shared, and modifications to it will be visible in the original.
  ByteBufBase readSlice(int offset, int length) =>
      new ByteBufBase._(_bytes, offset, length, length);

  /// Creates a new [ByteBufBase] that is a view of [this].  The underlying
  /// [Uint8List] is shared, and modifications to it will be visible in the original.
  ByteBufBase writeSlice(int offset, int length) =>
      new ByteBufBase._(_bytes, offset, offset, length);

  /// Creates a new [ByteBufBase] that is a [sublist] of [this].  The underlying
  /// [Uint8List] is shared, and modifications to it will be visible in the original.
  ByteBufBase sublist(int start, int end) =>
      new ByteBufBase._(_bytes, start, end - start, end - start);


  //*** Operators ***


  /// Sets the byte (Uint8) at [index] to [value].
  void operator []=(int index, int value) {
    setUint8(index, value);
  }

  @override
  bool operator ==(Object object) =>
      (this == object) ||
          ((object is ByteBufBase) && (this.hashCode == object.hashCode));

  //*** Internal Utilities ***

  /// Returns the length of the underlying [Uint8List].
  int get lengthInBytes => _bytes.lengthInBytes;

  /// Checks that the [readIndex] is valid;
  void _checkReadIndex(int index, [int lengthInBytes = 1]) {
    //print("checkReadIndex: index($index), lengthInBytes($lengthInBytes)");
    //print("checkReadIndex: readIndex($_readIndex), writeIndex($_writeIndex)");
    if ((index < _readIndex) || ((index + lengthInBytes) > writeIndex))
      indexOutOfBounds(index, "read");
  }

  /// Checks that the [writeIndex] is valid;
  void _checkWriteIndex(int index, [int lengthInBytes = 1]) {
    if (((index < _writeIndex) || (index + lengthInBytes) >= _bytes.lengthInBytes))
      indexOutOfBounds(index, "write");
  }

  /// Checks that there are at least [minimumReadableBytes] available.
  void _checkReadableBytes(int minimumReadableBytes) {
    if (_readIndex > (_writeIndex - minimumReadableBytes))
      throw new RangeError(
          "readIndex($readIndex) + length($minimumReadableBytes) "
              "exceeds writeIndex($writeIndex): #this");
  }

  /// Checks that there are at least [minimumWritableableBytes] available.
  void _checkWritableBytes(int minimumWritableBytes) {
    if ((_writeIndex + minimumWritableBytes) > lengthInBytes)
      throw new RangeError(
          "writeIndex($writeIndex) + minimumWritableBytes($minimumWritableBytes) "
              "exceeds lengthInBytes($lengthInBytes): $this");
  }

  /// Sets the [readIndex] to [index].  If [index] is not valid a [RangeError] is thrown.
  ByteBufBase setReadIndex(int index) {
    if (index < 0 || index > _writeIndex)
      throw new RangeError("readIndex: $index "
          "(expected: 0 <= readIndex <= writeIndex($_writeIndex))");
    _readIndex = index;
    return this;
  }

  /// Sets the [writeIndex] to [index].  If [index] is not valid a [RangeError] is thrown.
  ByteBufBase setWriteIndex(int index) {
    if (index < _readIndex || index > capacity)
      throw new RangeError(
          "writeIndex: $index (expected: readIndex($_readIndex) <= writeIndex <= capacity($capacity))");
    _writeIndex = index;
    return this;
  }

  /// Sets the [readIndex] and [writeIndex].  If either is not valid a [RangeError] is thrown.
  ByteBufBase setIndices(int readIndex, int writeIndex) {
    if (readIndex < 0 || readIndex > writeIndex || writeIndex > capacity)
      throw new RangeError("readIndex: $readIndex, writeIndex: $writeIndex "
          "(expected: 0 <= readIndex <= writeIndex <= capacity($capacity))");
    _readIndex = readIndex;
    _writeIndex = writeIndex;
    return this;
  }


  //*** Getters and Setters ***

  @override
  int get hashCode => _bytes.hashCode;

  /// Returns the current value of the index where the next read will start.
  int get readIndex => _readIndex;

  /// Sets the [readIndex] to [index].
  set readIndex(int index) {
    setReadIndex(index);
  }

  /// Returns the current value of the index where the next write will start.
  int get writeIndex => _writeIndex;

  /// Sets the [writeIndex] to [index].
  set writeIndex(int index) {
    setWriteIndex(index);
  }

  /// Returns [true] if [this] is a read only.
  bool get isReadOnly => false;

  //TODO: create subclass
  /// Returns an unmodifiable version of [this].
  /// Note: an UnmodifiableByteBuf can still be read.
  //BytebBufBase get asReadOnly => new UnmodifiableByteBuf(this);

  //*** ByteBuf [_bytes] management

  /// Returns the number of bytes (octets) this buffer can contain.
  int get capacity => _bytes.lengthInBytes;

  /// Returns [true] if there are readable bytes available, false otherwise.
  bool get isReadable => _writeIndex > _readIndex;

  /// Returns [true] if there are [numBytes] available to read, false otherwise.
  bool hasReadable(int numBytes) => _writeIndex - _readIndex >= numBytes;

  /// Returns [true] if there are writable bytes available, false otherwise.
  bool get isWritable => lengthInBytes > _writeIndex;

  /// Returns [true] if there are [numBytes] available to write, false otherwise.
  bool hasWritable(int numBytes) => lengthInBytes - _writeIndex >= numBytes;

  /// Returns the number of readable bytes.
  int get readableBytes => _writeIndex - _readIndex;

  /// Returns the number of writable bytes.
  int get writableBytes => lengthInBytes - _writeIndex;

  //*** Buffer Management Methods ***

  void checkReadableBytes(int minimumReadableBytes) {
    if (minimumReadableBytes < 0)
      throw new ArgumentError("minimumReadableBytes: $minimumReadableBytes (expected: >= 0)");
    _checkReadableBytes(minimumReadableBytes);
  }

  void checkWritableBytes(int minimumWritableBytes) {
    if (minimumWritableBytes < 0)
      throw new ArgumentError("minimumWritableBytes: $minimumWritableBytes (expected: >= 0)");
    _checkWritableBytes(minimumWritableBytes);
  }

  /// Ensures that there are at least [minReadableBytes] available to read.
  void ensureReadable(int minReadableBytes) {
    if (minReadableBytes < 0)
      throw new ArgumentError("minWritableBytes: $minReadableBytes (expected: >= 0)");
    if (minReadableBytes > readableBytes)
      throw new RangeError("writeIndex($_writeIndex) + "
          "minWritableBytes($minReadableBytes) exceeds lengthInBytes($lengthInBytes): $this");
    return;
  }

  /// Ensures that there are at least [minWritableBytes] available to write.
  void ensureWritable(int minWritableBytes) {
    if (minWritableBytes < 0)
      throw new ArgumentError("minWritableBytes: $minWritableBytes (expected: >= 0)");
    if (minWritableBytes > writableBytes)
      throw new RangeError("writeIndex($_writeIndex) + "
          "minWritableBytes($minWritableBytes) exceeds lengthInBytes($lengthInBytes): $this");
    return;
  }

  /// Compares the content of [this] to the content
  /// of [other].  Comparison is performed in a similar
  /// manner to the [String.compareTo] method.
  int compareTo(ByteBufBase other) {
    if (this == other) return 0;
    final int len = readableBytes;
    final int oLen = other.readableBytes;
    final int minLength = math.min(len, oLen);

    int aIndex = readIndex;
    int bIndex = other.readIndex;
    for (int i = 0; i < minLength; i++) {
      if (this[aIndex] > other[bIndex])
        return 1;
      if (this[aIndex] < other[bIndex])
        return -1;
    }
    // The buffers are == upto minLength, so...
    return len - oLen;
  }

  String toHex(int start, int end) {
    var s = "";
    for (int i = start; i < end; i++)
      s += _bytes[i].toRadixString(16).padLeft(2, " 0") + " ";
    return s;
  }

  String get info => """
  ByteBuf $hashCode
    rdIdx: $_readIndex,
    bytes: '${toHex(_readIndex, _writeIndex)}'
    string:'${_bytes.sublist(_readIndex, _writeIndex).toString()}'
    wrIdx: $_writeIndex,
    remaining: ${capacity - _writeIndex }
    cap: $capacity,
    maxCap: $lengthInBytes
  """;

  void debug() => print(info);

  @override
  String toString() => 'ByteBuf (rdIdx: $_readIndex, wrIdx: '
      '$_writeIndex, cap: $capacity, maxCap: $lengthInBytes)';

  //*** Error Methods ***

  ///
  void indexOutOfBounds(int index, String type) {
    // print("indexOutOfBounds: index($index), type($type)");
    // print("indexOutOfBounds: readIndex($_readIndex), writeIndex($_writeIndex)");
    String s;
    if (type == "read")
      s = "Invalid Read Index($index): $index "
          "(readIndex($readIndex) <= index($index) < writeIndex($writeIndex)";
    if (type == "write")
      s = "Invalid Write Index($index): $index to ByteBuf($this) with lengthInB "
          "(writeIndex($writeIndex) <= index($index) < capacity(${_bytes.lengthInBytes})";
    throw new RangeError(s);
  }
}