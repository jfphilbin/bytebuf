// Copyright (c) 2016, Open DICOMweb Project. All rights reserved.
// Use of this source code is governed by the open source license
// that can be found in the LICENSE file.
// Author: Jim Philbin <jfphilbin@gmail.edu>
// See the AUTHORS file for other contributors.
library bytebuf.bytebuf;

import 'dart:typed_data';

import 'bytebuf_reader.dart';

class ByteBuf extends ByteBufReader {

  /// Creates a new [ByteBuf] of [maxCapacity], where
  ///  [readIndex] = [writeIndex] = 0.
  factory ByteBuf([int lengthInBytes = ByteBufReader.defaultLengthInBytes]) {
    if (lengthInBytes == null)
      lengthInBytes = ByteBufReader.defaultLengthInBytes;
    if ((lengthInBytes < 0) || (lengthInBytes > ByteBufReader.maxMaxCapacity))
      throw new ArgumentError("lengthInBytes: $lengthInBytes "
          "(expected: 0 <= lengthInBytes <= maxCapacity($ByteBufReader.maxMaxCapacity)");
    return new ByteBuf._(new Uint8List(lengthInBytes), 0, 0, lengthInBytes);
  }


  //*** Operators ***


  /// Sets the byte (Uint8) at [index] to [value].
  void operator []=(int index, int value) {
    setUint8(index, value);
  }

  //*** Bytes set, write

  /// Stores a 8-bit integer at [index].
  ByteBuf setByte(int index, int value) => setUint8(index, value);

  /// Stores a 8-bit integer at [readIndex] and advances [readIndex] by 1.
  ByteBuf writeByte(int value) => writeUint8(value);

  //*** Write Boolean

  /// Stores a [bool] value at [index] as byte (Uint8),
  /// where 0 = [false], and any other value = [true].
  ByteBuf setBoolean(int index, bool value) {
    setUint8(index, value ? 1 : 0);
    return this;
  }

  /// Stores a [bool] value at [index] as byte (Uint8),
  /// where 0 = [false], and any other value = [true].
  ByteBuf writeBoolean(int index, bool value) {
    setUint8(_writeIndex, value ? 1 : 0);
    _writeIndex++;
    return this;
  }

  /// Stores a [List] of [bool] values from [index] as byte (Uint8),
  /// where 0 = [false], and any other value = [true].
  ByteBuf setBooleanList(int index, List<int> list) {
    _checkWriteIndex(index, list.length);
    for (int i = 0; i < list.length; i++)
      setInt8(index, list[i]);
    return this;
  }

  /// Stores a [List] of [bool] values from [writeIndex] as byte (Uint8),
  /// where 0 = [false], and any other value = [true].
  ByteBuf writeBooleanList(List<int> list) {
    setBooleanList(_writeIndex, list);
    _writeIndex += list.length;
    return this;
  }


  //*** Write Int8

  /// Stores a Int8 value at [index].
  ByteBuf setInt8(int index, int value) {
    _checkWriteIndex(index);
    _bd.setInt8(index, value);
    return this;
  }

  /// Stores a Int8 value at [writeIndex], and advances
  /// [writeIndex] by 1.
  ByteBuf writeInt8(int value) {
    setInt8(_writeIndex, value);
    _writeIndex++;
    return this;
  }

  /// Stores a [List] of Uint8 [int] values at [index].
  ByteBuf setInt8List(int index, List<int> list) {
    _checkWriteIndex(index, list.length);
    for (int i = 0; i < list.length; i++) {
      setInt8(index, list[i]);
      index += 1;
    }
    return this;
  }

  /// Stores a [List] of Uint8 [int] values at [writeIndex], and advances
  /// [writeIndex] by [List] [length]
  ByteBuf writeInt8List(List<int> list) {
    setInt8List(_writeIndex, list);
    _writeIndex += list.length;
    return this;
  }

  //*** Uint8 set, write

  /// Stores a Uint8 value at [index].
  ByteBuf setUint8(int index, int value) {
    _checkWriteIndex(index);
    _bd.setUint8(index, value);
    return this;
  }

  /// Stores a Uint8 value at [writeIndex], and advances [writeIndex] by 1.
  ByteBuf writeUint8(int value) {
    setUint8(_writeIndex, value);
    _writeIndex++;
    return this;
  }

  /// Stores a [List] of Uint8 values at [index].
  ByteBuf setUint8List(int index, List<int> list) {
    _checkWriteIndex(index, list.length);
    for (int i = 0; i < list.length; i++)
      setUint8(index + i, list[i]);
    return this;
  }

  /// Stores a [List] of Uint8 values at [writeIndex],
  /// and advances [writeIndex] by [List] [length].
  ByteBuf writeUint8List(List<int> list) {
    setUint8List(_writeIndex, list);
    _writeIndex += list.length;
    return this;
  }

  //*** Int16 set, write

  /// Stores an Int16 value at [index].
  ByteBuf setInt16(int index, int value) {
    _checkWriteIndex(index, 2);
    _bd.setInt16(index, value,endianness);
    return this;
  }

  /// Stores an Int16 value at [writeIndex], and advances [writeIndex] by 2.
  ByteBuf writeInt16(int value) {
    setInt16(_writeIndex, value);
    _writeIndex += 2;
    return this;
  }

  /// Stores a [List] of Int16 values at [index].
  ByteBuf setInt16List(int index, List<int> list) {
    _checkWriteIndex(index, list.length);
    for (int i = 0; i < list.length; i++) {
      setInt16(index, list[i]);
      index += 2;
    }
    return this;
  }

  /// Stores a [List] of Int16 values at [writeIndex],
  /// and advances [writeIndex] by ([list] [length] * 2).
  ByteBuf writeInt16List(List<int> list) {
    setInt16List(_writeIndex, list);
    _writeIndex += (list.length * 2);
    return this;
  }

  //*** Uint16 set, write litte Endian

  /// Stores a Uint16 value at [index],
  ByteBuf setUint16(int index, int value) {
    _checkWriteIndex(index, 2);
    _bd.setInt16(index, value, endianness);
    return this;
  }

  /// Stores a Uint16 value at [writeIndex],
  /// and advances [writeIndex] by 2.
  ByteBuf writeUint16(int value) {
    setUint16(_writeIndex, value);
    _writeIndex += 2;
    return this;
  }

  /// Stores a [List] of Uint16 values at [index].
  ByteBuf setUint16List(int index, List<int> list) {
    _checkWriteIndex(index, list.length);
    for (int i = 0; i < list.length; i++) {
      setUint16(index, list[i]);
      index += 2;
    }
    return this;
  }

  /// Stores a [List] of Uint16 values at [writeIndex],
  /// and advances [writeIndex] by ([list] [length] * 2).
  ByteBuf writeUint16List(List<int> list) {
    setUint16List(_writeIndex, list);
    _writeIndex += (list.length * 2);
    return this;
  }

  //*** Int32 set, write ***

  /// Stores an Int32 value at [index].
  ByteBuf setInt32(int index, int value) {
    _checkWriteIndex(index, 4);
    _bd.setInt32(index, value, endianness);
    return this;
  }

  /// Stores an Int32 value at [writeIndex],
  /// and advances [writeIndex] by 4.
  ByteBuf writeInt32(int value) {
    setInt32(_writeIndex, value);
    _writeIndex += 4;
    return this;
  }

  /// Stores a [List] of Int32 values at [index],
  ByteBuf setInt32List(int index, List<int> list) {
    _checkWriteIndex(index, list.length);
    for (int i = 0; i < list.length; i++) {
      setInt32(index, list[i]);
      index += 4;
    }
    return this;
  }

  /// Stores a [List] of Int32 values at [writeIndex],
  /// and advances [writeIndex] by ([list] [length] * 4).
  ByteBuf writeInt32List(List<int> list) {
    setInt32List(_writeIndex, list);
    _writeIndex += (list.length * 4);
    return this;
  }

  //*** Uint32 set, write

  /// Stores a Uint32 value at [index].
  ByteBuf setUint32(int index, int value) {
    _checkWriteIndex(index, 4);
    _bd.setUint32(index, value, endianness);
    return this;
  }

  /// Stores a Uint32 value at [writeIndex],
  /// and advances [writeIndex] by 4.
  ByteBuf writeUint32(int value) {
    setUint32(_writeIndex, value);
    _writeIndex += 4;
    return this;
  }

  /// Stores a [List] of Uint32 values at [index].
  ByteBuf setUint32List(int index, List<int> list) {
    _checkWriteIndex(index, list.length);
    for (int i = 0; i < list.length; i++) {
      setUint32(index, list[i]);
      index += 4;
    }
    return this;
  }

  /// Stores a [List] of Uint32 values at [writeIndex],
  /// and advances [writeIndex] by ([list] [length] * 4).
  ByteBuf writeUint32List(List<int> list) {
    setUint32List(_writeIndex, list);
    _writeIndex += (list.length * 4);
    return this;
  }

  //*** Int64 set, write

  /// Stores an Int64 values at [index].
  ByteBuf setInt64(int index, int value) {
    _checkWriteIndex(index, 8);
    _bd.setInt64(index, value, endianness);
    return this;
  }

  /// Stores an Int64 values at [writeIndex],
  /// and advances [writeIndex] by 8.
  ByteBuf writeInt64(int value) {
    setInt64(_writeIndex, value);
    _writeIndex += 8;
    return this;
  }

  /// Stores a [List] of Int64 values at [index].
  ByteBuf setInt64List(int index, List<int> list) {
    _checkWriteIndex(index, list.length);
    for (int i = 0; i < list.length; i++) {
      setInt64(index, list[i]);
      index += 8;
    }
    return this;
  }

  /// Stores a [List] of Int64 values at [writeIndex],
  /// and advances [writeIndex] by ([list] [length] * 8).
  ByteBuf writeInt64List(List<int> list) {
    setInt64List(_writeIndex, list);
    _writeIndex += (list.length * 8);
    return this;
  }

  //*** Uint64 set, write

  /// Stores a Uint64 value at [index].
  ByteBuf setUint64(int index, int value) {
    _checkWriteIndex(index, 8);
    _bd.setUint64(index, value, endianness);
    return this;
  }

  /// Stores a Uint64 value at [writeIndex],
  /// and advances [writeIndex] by 8.
  ByteBuf writeUint64(int value) {
    setUint64(_writeIndex, value);
    _writeIndex += 8;
    return this;
  }

  /// Stores a [List] of Uint64 values at [index].
  ByteBuf setUint64List(int index, List<int> list) {
    _checkWriteIndex(index, list.length);
    for (int i = 0; i < list.length; i++) {
      setUint64(index, list[i]);
      index += 8;
    }
    return this;
  }

  /// Stores a [List] of Uint64 values at [writeIndex],
  /// and advances [writeIndex] by ([list] [length] * 8).
  ByteBuf writeUint64List(List<int> list) {
    setUint64List(_writeIndex, list);
    _writeIndex += (list.length * 8);
    return this;
  }

  //*** Float32 set, write

  /// Stores a Float32 value at [index].
  ByteBuf setFloat32(int index, double value) {
    _checkWriteIndex(4);
    _bd.setFloat32(index, value, endianness);
    return this;
  }

  /// Stores a Float32 value at [writeIndex],
  /// and advances [writeIndex] by 4.
  ByteBuf writeFloat32(double value) {
    setFloat32(_writeIndex, value);
    _writeIndex += 4;
    return this;
  }

  /// Stores a [List] of Float32 values at [index].
  ByteBuf setFloat32List(int index, List<double> list) {
    _checkWriteIndex(index, list.length);
    for (int i = 0; i < list.length; i++) {
      setFloat32(index, list[i]);
      index += 4;
    }
    return this;
  }

  /// Stores a [List] of Float32 values at [writeIndex],
  /// and advances [writeIndex] by ([list] [length] * 4).
  ByteBuf writeFloat32List(List<double> list) {
    setFloat32List(_writeIndex, list);
    _writeIndex += (list.length * 4);
    return this;
  }

  //*** Float64 set, write

  /// Stores a Float64 value at [index],
  ByteBuf setFloat64(int index, double value) {
    _checkWriteIndex(8);
    _bd.setFloat64(index, value, endianness);
    return this;
  }

  /// Stores a Float64 value at [writeIndex],
  /// and advances [writeIndex] by 8.
  ByteBuf writeFloat64(double value) {
    setFloat64(_writeIndex, value);
    _writeIndex += 8;
    return this;
  }

  /// Stores a [List] of Float64 values at [index].
  ByteBuf setFloat64List(int index, List<double> list) {
    _checkWriteIndex(index, list.length);
    for (int i = 0; i < list.length; i++) {
      setFloat64(index, list[i]);
      index += 8;
    }

    return this;
  }

  /// Stores a [List] of Float64 values at [writeIndex],
  /// and advances [writeIndex] by ([list] [length] * 8).
  ByteBuf writeFloat64List(List<double> list) {
    setFloat64List(_writeIndex, list);
    _writeIndex += (list.length * 8);
    return this;
  }

  //*** String set, write
  //TODO: add Charset parameter

  /// Internal: Store the [String] [value] at [index] in this [ByteBuf].
  int _setString(int index, String value) {
    Uint8List list = UTF8.encode(value);
    _checkWriteIndex(index, list.length);
    for (int i = 0; i < list.length; i++)
      _bytes[index + i] = list[i];
    return list.length;
  }

  /// Store the [String] [value] at [index].
  ByteBuf setString(int index, String value) {
    _setString(index, value);
    return this;
  }

  /// Store the [String] [value] at [writeIndex].
  /// and advance [writeIndex] by the [length] of the decoded string.
  ByteBuf writeString(String value) {
    var length = _setString(_writeIndex, value);
    _writeIndex += length;
    return this;
  }

  int stringListLength(List<String> list) {
    int length = 0;
    for(int i = 0; i < list.length; i++) {
      length += list[i].length;
      length++;
    }
    return length;
  }

  /// Converts the [List] of [String] into a single [String] separated
  /// by [delimiter], encodes that string into UTF-8, and store the
  /// UTF-8 string at [index].
  ByteBuf setStringList(int index, List<String> list, [String delimiter = r"\"]) {
    String s = list.join(delimiter);
    _checkWriteIndex(index, s.length);
    _setString(index, s);
    return this;
  }

  /// Converts the [List] of [String] into a single [String] separated
  /// by [delimiter], encodes that string into UTF-8, and stores the UTF-8
  /// string at [writeIndex]. Finally, it advances [writeIndex]
  /// by the [length] of the encoded string.
  ByteBuf writeStringList(List<String> list, [String delimiter = r"\"]) {
    String s = list.join(delimiter);
    var length = _setString(_writeIndex, s);
    _writeIndex += length;
    return this;
  }



  ByteBuf skipReadBytes(int length) {
    _checkReadableBytes(length);
    _readIndex += length;
    return this;
  }

  ByteBuf unwriteBytes(int length) {
    _checkWriteIndex(_writeIndex, - length);
    _writeIndex -= length;
    return this;
  }

}