// Copyright (c) 2016, Open DICOMweb Project. All rights reserved.
// Use of this source code is governed by the open source license
// that can be found in the LICENSE file.
// Author: Jim Philbin <jfphilbin@gmail.edu>
// See the AUTHORS file for other contributors.
library odw.sdk.utilities.byte_array.byte_buf_reader;

import 'dart:typed_data';

import 'package:ascii/ascii.dart';

import 'utils.dart';

//TODO: update [checkRange]
//TODO: rename to Uint8Buffer (or Uint8Reader, Uint8Writer, Uint8Buffer)
//TODO: add write functionality
//TODO: rename to Uint8Buffer (or Uint8Reader, Uint8Writer, Uint8Buffer)
//TODO: add write functionality

//TODO: edit comment
/// A library for reading values from a [Uint8List], aka [ByteBufReader]
///
/// Supports reading in both BIG_ENDIAN and LITTLE_ENDIAN byte arrays. The default
/// Endianness is the endianness of the host [this] is running on, aka HOST_ENDIAN.
/// All read* methods advance the [_readIndex] by the number of bytes read.

//TODO: edit all doc comments below.
class ByteBufReader {
  /// The Endianness can be set before using
  Endianness endianness = Endianness.HOST_ENDIAN;
  /// The underlying [ByteBuffer].
  final ByteBuffer _buffer;
  /// The [Uint8List] view.
  final Uint8List _bytes;
  /// The [ByteData] view.
  final ByteData _bd;
  /// The index at which reading starts.
  int _start;
  /// The index of the last byte + 1;
  int _end;
  /// The current read position in the buffer.
  int _readIndex;

  /// Returns a [new] [ByteArray] [length] bytes long.
  factory ByteBufReader(Uint8List bytes, [int offset = 0, int length]) {
    int end = checkView(bytes.buffer, offset, length);
    return new ByteBufReader._(bytes, offset, end);
  }

  //TODO: doesn't handle Endiannes should it?
  /// Constructs a [new] [ByteArray] of [length]. The default length is 1024.
  ByteBufReader._(Uint8List bytes, int offset, int length)
      : _buffer = bytes.buffer,
        _bytes = bytes.buffer.asUint8List(offset, length),
        _bd = bytes.buffer.asByteData(offset, length),
        _start = offset,
        _end = offset + length,
        _readIndex = 0;

 /* TODO: needed?
  /// Returns a [new] [ByteBufReader] with [length] = end created from a [ByteBuffer][length] bytes long.
  factory ByteBufReader.fromByteBuf(ByteBuf bytes, [int start = 0, int length]) {
    Uint8List bytes = _buffer.asUint8List(start, length);
    return new ByteBufReader._(bytes.buffer,  0, bytes.length);
  }

  factory ByteBufReader.fromBytes(Uint8List bytes, [start = 0, int length]) {
    return new ByteBufReader(bytes.buffer,  0, bytes.length);
  }
  */

  factory ByteBufReader.view(Uint8List bytes, [int offset = 0, int length]) {
    checkView(bytes.buffer, offset, length);
    return new ByteBufReader._(bytes,  offset, length);
  }

  ByteBufReader slice([int start = 0, int length]) =>
    new ByteBufReader._(_bytes,  0, length);

  /// Returns a new [ByteBufReader] that is a copy of [this] from [start]
  /// inclusive to [end] exclusive, unless [start == 0] and [end == null]
  /// in which case [this] is returned.
  ByteBufReader sublist(int start, [int end]) =>
      ((start == 0) && (end == null)) ? this : new ByteBufReader(_bytes, start, end);

  //TODO: this needs to check [i]
  int operator [](int i) => _bytes[i];

  //TODO: this needs to check [i] and [val]
  void operator []=(int i, int val) { _bytes[i] = val; }

  int get length => _end - _start;

  int get remaining => _end - _readIndex;

  bool get isEmpty => _readIndex >= _end;

  bool get isNotEmpty => !isEmpty;

  int seek(int n) {
    checkRange(_readIndex, kByteLength, n, "seek");
    return _readIndex += n;
  }

  int getLimit(int lengthInBytes) {
    int localLimit = _readIndex + lengthInBytes;
    if(localLimit > _end) throw "length $lengthInBytes too long";
    return localLimit;
  }

  int checkLength(int offsetInBytes) {
    if (offsetInBytes > _end) throw "Offset $offsetInBytes too long";
    return _readIndex - offsetInBytes;
  }

  //Flush:? not used
  //TODO add to Warnings
  int checkLimit(int index) => (index >= _end) ? _end : index;

  void checkRange(int offset, int unitLength, int lengthInBytes, String caller) {
    print('checkRange: offset =$offset, unitLength=$unitLength, lengthInBytes=$lengthInBytes, caller=$caller');
    if ((lengthInBytes % unitLength) != 0)
      throw '$caller: Invalid Length=$lengthInBytes for UnitLength=$unitLength';
    print('offset=$offset');
    if(offset < _start) {
      throw '$caller: offset cannot be less than 0: offset = $offset';
    }
    int end = offset + lengthInBytes;
    if (end > _end) {
      throw '$caller: attempt to read past end of buffer: end = $end';
    }
  }

  /// Returns an unsigned 8-bit [int]. [offset] is an absolute offset
  /// in [_bytes].
  int getUint8(int offset) {
    checkRange(offset, kUint8NBytes, kUint8NBytes, "getUint8");
    return _bd.getUint8(offset);
  }

  /// Returns an unsigned 8-bit [int] from the current [_readIndex]
  /// in [_bytes] and increments the [_readIndex]  by 1.
  /// Throws an error if [_readIndex] is out of range.
  int readUint8() {
    int value = getUint8(_readIndex);
    _readIndex ++;
    return value;
  }

  /// Returns a [Uint8List] of length [lengthInBytes]. [offset] i
  /// s an absolute offset in [_bytes].
  List<int> getUint8List(int offset, int lengthInBytes) {
    checkRange(offset, kUint8NBytes, lengthInBytes, "getUint8List");
    return _bytes.buffer.asUint8List(offset, lengthInBytes);
  }

  /// Reads a [Uint8List] of length [lengthInBytes] from the current
  /// [_readIndex] in [_bytes] and increments the [_readIndex] by [lengthInBytes].
  /// Throws an error if [_readIndex] is out of range.
  List<int> readUint8List(int lengthInBytes) {
    List<int> value = getUint8List(_readIndex, lengthInBytes);
    _readIndex += lengthInBytes;
    return value;
  }

  /// [offset] is an absolute offset in the [_bytes]. Returns an unsigned 8 bit integer.
  /// Throws an error if [_readIndex] is out of reange.
  int getInt8(int offset) {
    checkRange(offset, kInt8NBytes, kInt8NBytes, "getInt8");
    return _bd.getInt8(offset);
  }

  /// Returns an unsigned 16 bit integer from [this] or throws and error.
  int readInt8() {
    int value = getInt8(_readIndex);
    _readIndex += 1;
    return value;
  }

  /// Returns an [Int8List] of length [lengthInBytes]. [offset]
  /// is an absolute offset in [_bytes].
  List<int> getInt8List(int offset, int lengthInBytes) {
    checkRange(offset, kInt8NBytes, lengthInBytes, "getInt8List");
    return _bytes.buffer.asInt8List(offset, lengthInBytes);
  }

  /// Returns an [Int8List] of length [lengthInBytes] from the current
  /// [_readIndex] in [_bytes] and increments the [_readIndex] by [lengthInBytes].
  /// Throws an error if [_readIndex] is out of range.
  List<int> readInt8List(int lengthInBytes) {
    List<int> value = getInt8List(_readIndex, lengthInBytes);
    _readIndex += lengthInBytes;
    return value;
  }

  /// Gets 16 bits at the absolute [offset] in the [_bytes]. Returns the unsigned 16
  ///  bit value as an [int].  Throws an error if [_readIndex] is out of reange.
  int getUint16(int offset) {
    checkRange(offset, kUint16NBytes, kUint16NBytes, "getUint16");
    return _bd.getUint16(offset, endianness);
  }

  /// Reads the 16 bits at the current [_readIndex] as an unsigned integer, increments
  /// the position by 2, and returns an [int].  Throws an error if [_readIndex] is out
  /// of range.
  int readUint16() {
    int value = getUint16(_readIndex);
    _readIndex += 2;
    return value;
  }

  /// Returns an [Uint8List] of length [lengthInBytes]. [offset]
  /// is an absolute offset in [_bytes].
  List<int> getUint16List(int offset, int lengthInBytes) {
    checkRange(offset, kUint16NBytes, lengthInBytes, "getUint16List");
    return _bytes.buffer.asUint16List(offset, lengthInBytes ~/ kUint16NBytes);
  }

  /// Returns an [Uint8List] of length [lengthInBytes] from the current
  /// [_readIndex] in [_bytes] and increments the [_readIndex] by [lengthInBytes].
  /// Throws an error if [_readIndex] is out of range.
  List<int> readUint16List(int lengthInBytes) {
    List<int> value = getUint16List(_readIndex, lengthInBytes);
    _readIndex += lengthInBytes;
    return value;
  }

  /// Returns an signed 16-bit [int] at the absolute [offset] in
  /// [_bytes].  Throws an error if [_readIndex] is out of range.
  int getInt16(int offset) {
    checkRange(offset, kInt16NBytes, kInt16NBytes, "getInt16");
    return _bd.getInt16(offset, endianness);
  }

  /// Returns an signed 16-bit [int] at [_readIndex] and increments
  /// the [_readIndex] by 2.
  int readInt16() {
    int value = getInt16(_readIndex);
    _readIndex += 2;
    return value;
  }

  /// Returns an [Int16List] of length [lengthInBytes]. [offset]
  /// is an absolute offset in [_bytes].
  List<int> getInt16List(int offset, int lengthInBytes) {
    checkRange(offset, kInt16NBytes, lengthInBytes, "getInt16List");
    return _bytes.buffer.asInt16List(offset, lengthInBytes ~/ kInt16NBytes);
  }

  /// Returns an [Int16List] of length [lengthInBytes] from the current
  /// [_readIndex] in [_bytes] and increments the [_readIndex] by [lengthInBytes].
  /// Throws an error if [_readIndex] is out of range.
  List<int> readInt16List(int lengthInBytes) {
    List<int> value = getInt16List(_readIndex, lengthInBytes);
    _readIndex += lengthInBytes;
    return value;
  }

  int getUint32(int offset) {
    checkRange(offset, kUint32NBytes, kUint32NBytes, "getUint32");
    return _bd.getUint32(offset, endianness);
  }

  /// Reads a 32 bit unsigned integer from the byte array.
  int readUint32() {
    int value = getUint32(_readIndex);
    _readIndex += 4;
    return value;
  }

  /// Returns an [Uint32List] of length [lengthInBytes]. [offset]
  /// is an absolute offset in [_bytes].
  List<int> getUint32List(int offset, int lengthInBytes) {
    checkRange(offset, kUint32NBytes, lengthInBytes, "getUint32List");
    return _bytes.buffer.asUint32List(offset, lengthInBytes ~/ kUint32NBytes);
  }

  /// Returns an [Uint32List] of length [lengthInBytes] from the current
  /// [_readIndex] in [_bytes] and increments the [_readIndex] by [lengthInBytes].
  /// Throws an error if [_readIndex] is out of range.
  List<int> readUint32List(int lengthInBytes) {
    List<int> value = getUint32List(_readIndex, lengthInBytes);
    _readIndex += lengthInBytes;
    return value;
  }

  int getInt32(int offset) {
    checkRange(offset, kInt32NBytes, kInt32NBytes, "getInt32");
    return _bd.getInt32(offset, endianness);
  }

  /// Reads a 32 bit signed integer from the byte array.
  int readInt32() {
    int value = getInt32(_readIndex);
    _readIndex += 4;
    return value;
  }

  /// Returns an [Int32List] of length [lengthInBytes]. [offset]
  /// is an absolute offset in [_bytes].
  List<int> getInt32List(int offset, int lengthInBytes) {
    checkRange(offset, kInt32NBytes, lengthInBytes, "getInt32List");
    return _bytes.buffer.asInt32List(offset, lengthInBytes ~/ kInt32NBytes);
  }

  /// Returns an [Int32List] of length [lengthInBytes] from the current
  /// [_readIndex] in [_bytes] and increments the [_readIndex] by [lengthInBytes].
  /// Throws an error if [_readIndex] is out of range.
  List<int> readInt32List(int lengthInBytes) {
    List<int> value = getInt32List(_readIndex, lengthInBytes);
    _readIndex += lengthInBytes;
    return value;
  }

  int getUint64(int offset) {
    checkRange(offset, kUint64NBytes, kUint64NBytes, "getUint64");
    return _bd.getUint64(offset, endianness);
  }

  /// Reads a 32 bit unsigned integer from the byte array.
  int readUint64() {
    int value = getUint64(_readIndex);
    _readIndex += 8;
    return value;
  }

  /// Returns an [Uint64List] of length [lengthInBytes]. [offset]
  /// is an absolute offset in [_bytes].
  List<int> getUint64List(int offset, int lengthInBytes) {
    checkRange(offset, kUint64NBytes, lengthInBytes, "getUint64List");
    return _bytes.buffer.asUint64List(offset, lengthInBytes ~/ kUint64NBytes);
  }

  /// Returns an [Uint64List] of length [lengthInBytes] from the current
  /// [_readIndex] in [_bytes] and increments the [_readIndex] by [lengthInBytes].
  /// Throws an error if [_readIndex] is out of range.
  List<int> readUint64List(int lengthInBytes) {
    List<int> value = getUint64List(_readIndex, lengthInBytes);
    _readIndex += lengthInBytes;
    return value;
  }

  int getInt64(int offset) {
    checkRange(offset, kInt64NBytes, kInt64NBytes, "getInt64");
    return _bd.getInt64(offset, endianness);
  }

  /// Reads a 32 bit signed integer from the byte array.
  int readInt64() {
    int value = getInt64(_readIndex);
    _readIndex += 8;
    return value;
  }

  /// Returns an [Int64List] of length [lengthInBytes]. [offset]
  /// is an absolute offset in [_bytes].
  List<int> getInt64List(int offset, int lengthInBytes) {
    checkRange(offset, kInt64NBytes, lengthInBytes, "getInt64List");
    return _bytes.buffer.asInt64List(offset, lengthInBytes ~/ kInt64NBytes);
  }

  /// Returns an [Int64List] of length [lengthInBytes] from the current
  /// [_readIndex] in [_bytes] and increments the [_readIndex] by [lengthInBytes].
  /// Throws an error if [_readIndex] is out of range.
  List<int> readInt64List(int lengthInBytes) {
    List<int> value = getInt64List(_readIndex, lengthInBytes);
    _readIndex += lengthInBytes;
    return value;
  }

  double getFloat32(int offset) {
    checkRange(offset, kFloat32NBytes, kFloat32NBytes, "getFloat32");
    return _bd.getFloat32(offset, endianness);
  }

  /// Synonym for getFloat32
  double getFLoat(int offset) => getFloat32(offset);

  /// Reads a 32 bit floating point number from the byte array.
  double readFloat32() {
    double value = getFloat32(_readIndex);
    _readIndex += 4;
    return value;
  }

  /// Synonym for readFloat32
  double readFloat() => readFloat32();

  /// Returns an [Float32List] of length [lengthInBytes]. [offset]
  /// is an absolute offset in [_bytes].
  List<double> getFloat32List(int offset, int lengthInBytes) {
    checkRange(offset, kFloat32NBytes, lengthInBytes, "getFloat32List");
    return _bytes.buffer.asFloat32List(offset, lengthInBytes ~/ kFloat32NBytes);
  }

  /// Returns an [Float32List] of length [lengthInBytes] from the current
  /// [_readIndex] in [_bytes] and increments the [_readIndex] by [lengthInBytes].
  /// Throws an error if [_readIndex] is out of range.
  List<double> readFloat32List(int lengthInBytes) {
    List<double> value = getFloat32List(_readIndex, lengthInBytes);
    _readIndex += lengthInBytes;
    return value;
  }

  /// Synonym for readFloat32List
  List<double> readFloatList(int lengthInBytes) =>
      readFloat32List(lengthInBytes);

  double getFloat64(int offset) {
    checkRange(offset, kFloat64NBytes, kFloat64NBytes, "getFloat64");
    return _bd.getFloat64(offset, endianness);
  }

  /// Reads a 64 bit floating point number from the byte array.
  double readFloat64() {
    double value = getFloat64(_readIndex);
    _readIndex += 8;
    return value;
  }

  /// Synonym for readFloat64
  double readDouble() => readFloat64();

  /// Returns an [Float64List] of length [lengthInBytes]. [offset]
  /// is an absolute offset in [_bytes].
  List<double> getFloat64List(int offset, int lengthInBytes) {
    checkRange(offset, kFloat64NBytes, lengthInBytes, "getFloat64List");
    return _bytes.buffer.asFloat64List(offset, lengthInBytes ~/ kFloat64NBytes);
  }

  /// Returns an [Float64List] of length [lengthInBytes] from the current
  /// [_readIndex] in [_bytes] and increments the [_readIndex] by [lengthInBytes].
  /// Throws an error if [_readIndex] is out of range.
  List<double> readFloat64List(int lengthInBytes) {
    List<double> value = getFloat64List(_readIndex, lengthInBytes);
    _readIndex += lengthInBytes;
    return value;
  }

  /// Synonym for readFloat32List
  List<double> readDoubleList(int lengthInBytes) =>
      readFloat64List(lengthInBytes);

  //TODO: Isn't there a faster way to do this? Should string trimming be done here?
  /*
  String getFixedString(int offset, int length) {
    checkRange(offset, length, 1, "FixedString");
    //var result = "";
    for(int i = offset; i < offset + length; i++) {
      int byte = bytes[i];
      if((byte == 0) || (byte == kBackslash)) {
        Uint8List charCodes = bytes.buffer.asUint8List(offset, i - offset);
        String s = new String.fromCharCodes(charCodes);
        //print('getFixedString1:"$s"');
        return s.trimRight();
      }
    }
    Uint8List charCodes = bytes.buffer.asUint8List(offset, length);
    String s = new String.fromCharCodes(charCodes);
    //print('getFixedString2:"$s"');
    return s.trimRight();
  }
  */
  //Enhancement: Which is better [getFixedString] or [getFixedString1]?  Does it matter?
  String getString(int offset, int length) {
    checkRange(offset, 1, length, "getString");
    Uint8List charCodes = _bytes.buffer.asUint8List(offset, length);
    var s = new String.fromCharCodes(charCodes);
    if ((s.codeUnitAt(length - 1) == kSpace) || (s.codeUnitAt(length - 1) == kNull))
      return s.substring(0, length - 1);
    return s;
  }

  /// Reads a string of 8 bit characters from the byte array.
  String readString(int length) {
    String s = getString(_readIndex, length);
    _readIndex += length;
    return s;
  }

  List<String> getStringList(int offset, int length) {
    checkRange(offset, kByteLength, length, "getStringList");
    var s = getString(offset, length);
    return s.split(r'\');
  }

  /// Reads a [List] of [String]s from the byte array.
  /// The backslash (reverse solidus) characters separates
  /// the [String]s.
  List<String> readStringList(int length) {
    var list = getStringList(_readIndex, length);
    _readIndex += length;
    return list;
  }
}
