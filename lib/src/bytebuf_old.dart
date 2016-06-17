// Copyright (c) 2016, Open DICOMweb Project. All rights reserved.
// Use of this source code is governed by the open source license
// that can be found in the LICENSE file.
// Author: Jim Philbin <jfphilbin@gmail.edu>
// See the AUTHORS file for other contributors.
library odw.sdk.base.utils.bytebuf;

import 'dart:typed_data';

import 'package:ascii/ascii.dart';

import 'utils.dart';

//TODO: rename to Uint8Buffer (or Uint8Reader, Uint8Writer, Uint8Buffer)
//TODO: add write functionality

//TODO: edit comment
/// A library for reading values from a [Uint8List], aka [ByteBuf]
///
/// Supports reading in both BIG_ENDIAN and LITTLE_ENDIAN. The default
/// Endianness is the endianness of the host [this] is running on, aka HOST_ENDIAN.
/// All read* methods advance the [position] by the number of bytes read.

//TODO: edit all doc comments below.
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
    return new ByteBuf._(bytes.buffer, 0, length);
  }

  /// Constructs a [new] [ByteArray] of [length]. The default length is 1024.
  ByteBuf._(ByteBuffer buffer, int offset, length)
      : _buffer = buffer,
        _bytes = buffer.asUint8List(offset, length),
        _bd = buffer.asByteData(offset, length),
        _start = offset,
        _end = offset + length;

  /// Creates a
  factory ByteBuf.fromByteBuf(ByteBuf bytes, [int offset = 0, int length]) {
    int end = checkView(bytes._buffer, offset, length);
    return new ByteBuf._(bytes._buffer, offset, end);
  }

  factory ByteBuf.view(ByteBuf bytes, [offset = 0, int length]) {
    int end = checkView(bytes._buffer, offset, length);
    return new ByteBuf._(bytes._buffer, offset, end);
  }

  /// Returns an unsigned 8-bit [int]. [offset] is an absolute offset
  /// in [_bytes].
  int getUint8(int offset) {
    checkRange(offset, 1, 1, "getUint8");
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
    checkRange(offset, 1, lengthInBytes, "getUint8List");
    return _bytes.buffer.asUint8List(offset, offset + lengthInBytes);
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
    checkRange(offset, 1, 1, "Int8");
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
    checkRange(offset, 1, lengthInBytes, "getInt8List");
    return _bytes.buffer.asInt8List(offset, offset + lengthInBytes);
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
    checkRange(offset, 1, 2, "getUint16");
    return _bd.getUint16(offset, endianness);
  }

  /// Reads the 16 bits at the current [_readIndex] as an unsigned integer, increments
  /// the _readIndex by 2, and returns an [int].  Throws an error if [_readIndex] is out
  /// of range.
  int readUint16() {
    int value = getUint16(_readIndex);
    _readIndex += 2;
    return value;
  }

  /// Returns an [Uint8List] of length [lengthInBytes]. [offset]
  /// is an absolute offset in [_bytes].
  List<int> getUint16List(int offset, int lengthInBytes) {
    checkRange(offset, 2, lengthInBytes, "getUint16List");
    return _bytes.buffer.asUint16List(offset, offset + lengthInBytes);
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
    checkRange(offset, 2, 2, "getInt16");
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
    checkRange(offset, 2, lengthInBytes, "getInt16List");
    return _bytes.buffer.asInt16List(offset, offset + lengthInBytes);
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
    checkRange(offset, 1, 4, "Uint32");
    return _bd.getUint32(offset, endianness);
  }

  /// Reads a 32 bit unsigned integer from the [ByteBuf].
  int readUint32() {
    int value = getUint32(_readIndex);
    _readIndex += 4;
    return value;
  }

  /// Returns an [Uint32List] of length [lengthInBytes]. [offset]
  /// is an absolute offset in [_bytes].
  List<int> getUint32List(int offset, int lengthInBytes) {
    checkRange(offset, 4, lengthInBytes, "getUint32List");
    return _bytes.buffer.asUint32List(offset, offset + lengthInBytes);
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
    checkRange(offset, 4, 4, "Int32");
    return _bd.getInt32(offset, endianness);
  }

  /// Reads a 32 bit signed integer from the [ByteBuf].
  int readInt32() {
    int value = getInt32(_readIndex);
    _readIndex += 4;
    return value;
  }

  /// Returns an [Int32List] of length [lengthInBytes]. [offset]
  /// is an absolute offset in [_bytes].
  List<int> getInt32List(int offset, int lengthInBytes) {
    checkRange(offset, 4, lengthInBytes, "getInt32List");
    return _bytes.buffer.asInt32List(offset, offset + lengthInBytes);
  }

  /// Returns an [Int32List] of length [lengthInBytes] from the current
  /// [_readIndex] in [_bytes] and increments the [_readIndex] by [lengthInBytes].
  /// Throws an error if [_readIndex] is out of range.
  List<int> readInt32List(int lengthInBytes) {
    List<int> value = getUint32List(_readIndex, lengthInBytes);
    _readIndex += lengthInBytes;
    return value;
  }

  int getUint64(int offset) {
    checkRange(offset, 8, 8, "Uint64");
    return _bd.getUint64(offset, endianness);
  }

  /// Reads a 32 bit unsigned integer from the [ByteBuf].
  int readUint64() {
    int value = getUint64(_readIndex);
    _readIndex += 8;
    return value;
  }

  /// Returns an [Uint64List] of length [lengthInBytes]. [offset]
  /// is an absolute offset in [_bytes].
  List<int> getUint64List(int offset, int lengthInBytes) {
    checkRange(offset, 8, lengthInBytes, "getUint64List");
    return _bytes.buffer.asUint64List(offset, offset + lengthInBytes);
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
    checkRange(offset, 8, 8, "Int64");
    return _bd.getInt64(offset, endianness);
  }

  /// Reads a 32 bit signed integer from the [ByteBuf].
  int readInt64() {
    int value = getInt64(_readIndex);
    _readIndex += 8;
    return value;
  }

  /// Returns an [Int64List] of length [lengthInBytes]. [offset]
  /// is an absolute offset in [_bytes].
  List<int> getInt64List(int offset, int lengthInBytes) {
    checkRange(offset, 8, lengthInBytes, "getInt64List");
    return _bytes.buffer.asInt64List(offset, offset + lengthInBytes);
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
    checkRange(offset, 4, 4, "Float32");
    return _bd.getFloat32(offset, endianness);
  }

  /// Synonym for getFloat32
  double getFLoat(int offset) => getFloat32(offset);

  /// Reads a 32 bit floating point number from the [ByteBuf].
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
    checkRange(offset, 4, lengthInBytes, "getFloat32List");
    return _bytes.buffer.asFloat32List(offset, offset + lengthInBytes);
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
    checkRange(offset, 8, 8, "Float64");
    return _bd.getFloat64(offset, endianness);
  }

  /// Reads a 64 bit floating point number from the [ByteBuf].
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
    checkRange(offset, 8, lengthInBytes, "getFloat64List");
    return _bytes.buffer.asFloat64List(offset, offset + lengthInBytes);
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
    checkRange(offset, length, 1, "getString");
    Uint8List charCodes = _bytes.buffer.asUint8List(offset, length);
    var s = new String.fromCharCodes(charCodes);
    if ((s.codeUnitAt(length - 1) == kSpace) || (s.codeUnitAt(length - 1) == kNull))
      return s.substring(0, length - 1);
    return s;
  }

  /// Reads a string of 8 bit characters from the [ByteBuf].
  String readString(int length) {
    String s = getString(_readIndex, length);
    _readIndex += length;
    return s;
  }

  List<String> getStringList(int offset, int length) {
    var s = getString(offset, length);
    return s.split(r'\');
  }

  /// Reads a [List] of [String]s from the [ByteBuf].
  /// The backslash (reverse solidus) characters separates
  /// the [String]s.
  List<String> readStringList(int length) {
    var list = getStringList(_readIndex, length);
    _readIndex += length;
    return list;
  }

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
}




