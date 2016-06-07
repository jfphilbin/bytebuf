// Copyright (c) 2016, Open DICOMweb Project. All rights reserved.
// Use of this source code is governed by the open source license
// that can be found in the LICENSE file.
// Author: Jim Philbin <jfphilbin@gmail.edu>
// See the AUTHORS file for other contributors.
library odw.sdk.utilities.byte_array.byte_buf_writer;

import 'dart:typed_data';

import 'package:byte_array/src/constants.dart';


//TODO: rename to Uint8Buffer (or Uint8Reader, Uint8Writer, Uint8Buffer)
//TODO: add write functionality
//TODO: Optimize List writing by only checking the Range once in the list procedure and separate
// setXX into external entry point the checks the length and internal entry point that doesn't.

//TODO: review and document

//TODO: edit comment
/// A library for writing values into a [Uint8List], aka [ByteBufWriter]
///
/// Supports writing in both BIG_ENDIAN and LITTLE_ENDIAN. The default
/// Endianness is the endianness of the host [this] is running on, aka HOST_ENDIAN.
/// All write* methods advance the [wrIdx] by the number of bytes written.


//TODO: edit all doc comments below.
class ByteBufWriter {
  static const elementSizeInBytes = 1;

  /// The Endianness can be set before using
  Endianness endianness = Endianness.HOST_ENDIAN;

  /// The underlying byte array, i.e. [Uint8List] object.
  final Uint8List bytes;

  /// The underlying [ByteData] object.
  final ByteData bd;

  /// The index at which writeing starts.
  final int start;

  /// The index of the last byte + 1;
  final int end;

  /// The current write position in the buffer.
  int wrIdx;

  /// Creates a new Uint8Writer [length] bytes long.
  factory ByteBufWriter([int length = 1000]) {
    if (length < 0) throw "Invalid length = $length";
    return new ByteBufWriter._(new Uint8List(length));
  }

  /// Internal Constructor
  /// Creates a new [ByteBufWriter] from an existing [Uint8List].  Changes to the
  /// underlying list are visable to the [this].  The created [ByteBufWriter] will begin
  /// at index [start] and end at index [end].
  ByteBufWriter._(Uint8List list, [int start = 0, int end])
      : end = (end == null) ? list.length : end,
        start = 0,
        wrIdx = 0,
        bytes = list,
        bd = list.buffer.asByteData() {
    if ((start < 0) || (end <= start)) throw "Invalid values: start=$start, end=$end";
  }

  /// Creates a [Uint8Winter.view] of the specified [ByteBufWriter].
  /// Changes in the [Uint8Winter] will be visible in the [ByteBufWriter.view] and vice versa.
  /// If the [offsetInBytes] index of the region is not specified, it defaults to zero
  /// (the first byte in the [ByteBufWriter]). If the length is not specified, it defaults
  /// to null, which indicates that the view extends to the end of the [ByteBufWriter.bytes].
  /// Throws RangeError if [offsetInBytes] or [length] are negative, or if
  /// [offsetInBytes] + ([length] * [elementSizeInBytes]) is greater than the length of buffer.
  factory ByteBufWriter.view(ByteBufWriter writer, [offsetInBytes = 0, int length]) {
    length = (length == null) ? writer.bytes.lengthInBytes : length;
    if ((offsetInBytes < 0) || (length < 0) || (offsetInBytes + length > writer.bytes.lengthInBytes))
      throw new RangeError("Invalid offsetInBytes=$offsetInBytes or length=$length");
    return new ByteBufWriter._(writer.bytes, offsetInBytes, offsetInBytes + length);
  }

  /// Creates an [Uint8Winter.view] of the specified region in [bytes].
  /// Changes in the [Int8writer] will be visible in the [Uint8Write.view] and vice versa.
  /// If the [offsetInBytes] index of the region is not specified, it defaults to zero
  /// (the first byte in the byte buffer). If the length is not specified, it defaults
  /// to null, which indicates that the view extends to the end of the byte buffer.
  /// Throws RangeError if [offsetInBytes] or [length] are negative, or if
  /// [offsetInBytes] + ([length] * [elementSizeInBytes]) is greater than the length of buffer.
  factory ByteBufWriter.fromBuffer(ByteBuffer buffer, [offsetInBytes = 0, int length]) {
    length = (length == null) ? buffer.lengthInBytes : length;
    if ((offsetInBytes < 0) || (length < 0) || (offsetInBytes + length > buffer.lengthInBytes))
      throw new RangeError("Invalid offsetInBytes=$offsetInBytes or length=$length");
    Uint8List bytes = buffer.asUint8List(offsetInBytes, length);
    return new ByteBufWriter._(bytes, 0, bytes.length);
  }

  /// Creates a [Uint8Winter] with the same length as the [elements] [List] and copies over the elements.
  /// Values are truncated to fit in the [Uint8List] when they are copied, the same way storing
  /// values truncates them. See [Uint8List.fromList].
  // TODO: buggy - is this one needed?
  factory ByteBufWriter.fromList(List<int> elements, [start = 0, int length]) {
    throw "unimplemented";
    if (length == null) length = elements.length;

    Uint8List bytes = new Uint8List.fromList(elements);
    return new ByteBufWriter._(bytes, 0, bytes.length);
  }

  /// Returns a new [ByteBufWriter] that is a copy of [this] from [start] inclusive to [end] exclusive.
  ByteBufWriter sublist(int start, [int end]) => new ByteBufWriter._(bytes, start, end);

  /// Returns a new [ByteBufWriter] that is a view of [this] from [start] inclusive to [end] exclusive.
  ByteBufWriter subview(int start, [int end]) => new ByteBufWriter._(bytes, start, end);

  int operator [](int i) => bytes[i];

  operator []=(int i, int val) => bytes[i] = val;

  int get length => end - start;

  int get remaining => end - wrIdx;

  bool get isEmpty => wrIdx == start;

  bool get isNotEmpty => !isEmpty;

  bool get isFull => wrIdx == end;

  bool get isNotFull => !isFull;

  int seek(int n) {
    checkRange(wrIdx, 1, n, "seek");
    return wrIdx += n;
  }

  //TODO: if needed test validate
  int getLimit(int lengthInBytes) {
    int localLimit = wrIdx + lengthInBytes;
    if (localLimit > end) throw "length $lengthInBytes too long";
    return localLimit;
  }

  //TODO: if needed test validate
  int checkLength(int offsetInBytes) {
    if (offsetInBytes > end) throw "Offset $offsetInBytes too long";
    return wrIdx - offsetInBytes;
  }

  //Flush:? not used
  //TODO add to Warnings
  int checkLimit(int index) => (index >= end) ? end : index;

  //TODO: fix and validate
  void checkRange(int offset, int unitLength, int length, String caller) {
    if ((offset < 0) || (offset >= end))
      throw "Invalid offset: $offset";
    int index = offset + (unitLength * length);
    if ((index < 0) || (index >= end))
      throw '$caller: Invalid Index=$index';
/* Flush?
    if (index < start) {
      throw '$caller: position cannot be less than 0';
    }
    if (index > end) {
      throw '$caller: attempt to write past end of buffer';
    }
 */
  }

  /// Stores an unsigned 8-bit [value] at [offset] is the offset in [bytes]
  void setUint8(int offset, int value) {
    checkRange(offset, uint8NBytes, 1, "setUint8");
    bd.setUint8(offset, value);
  }

  /// Stores an unsigned 8-bit [value] at [wrIdx] in [bytes] and increments the [wrIdx]  by 1.
  void writeUint8(int value) {
    setUint8(wrIdx, value);
    wrIdx ++;
  }

  /// Stores a [List<int>] at [offset] in [bytes].
  void setUint8List(int offset, List<int> list) {
    checkRange(offset, uint8NBytes, list.length, "setUint8List");
    for (int i = 0; i < list.length; i++)
      bd.setUint8(offset + i, list[i]);
  }

  /// Stores a [List<int>] at [wrIdx] in [bytes] and increments the [wrIdx] by [List] [length].
  void writeUint8List(List<int> list) {
    setUint8List(wrIdx, list);
    wrIdx += list.length;
  }

  /// [offset] is an absolute offset in the [bytes]. Returns an unsigned 8 bit integer.
  /// Throws an error if [wrIdx] is out of reange.
  void setInt8(int offset, int value) {
    checkRange(offset, int8NBytes, 1, "setInt8");
    return bd.setInt8(offset, value);
  }

  /// Returns an unsigned 16 bit integer from [this] or throws and error.
  void writeInt8(int value) {
    setInt8(wrIdx, value);
    wrIdx += 1;
  }

  /// Returns an [Int8List] of length [lengthInBytes]. [offset]
  /// is an absolute offset in [bytes].
  void setInt8List(int offset, List<int> list) {
    checkRange(offset, int8NBytes, list.length, "setInt8List");
    for (int i = 0; i < list.length; i++)
      bd.setInt8(offset + i, list[i]);
  }

  /// Returns an [Int8List] of length [lengthInBytes] from the current
  /// [wrIdx] in [bytes] and increments the [wrIdx] by [lengthInBytes].
  /// Throws an error if [wrIdx] is out of range.
  void writeInt8List(List<int> list) {
    setInt8List(wrIdx, list);
    wrIdx += list.length;
  }

  /// Sets 16 bits at the [offset] in [bytes] to [value].
  /// Throws an error if [wrIdx] is out of range.
  void setUint16(int offset, int value) {
    checkRange(offset, uint16NBytes, 1, "setUint16");
    return bd.setUint16(offset, value, endianness);
  }

  /// Write a 16 bit [int] at the current [wrIdx] as an unsigned integer and increments
  /// the [wrIdx] by 2.  Throws an error if [wrIdx] is out of range.
  void writeUint16(int value) {
    setUint16(wrIdx, value);
    wrIdx += 2;
  }

  /// Writes the [List]<int> at [offset] in [bytes].
  void setUint16List(int offset, List<int> list) {
    checkRange(offset, uint16NBytes, list.length, "setUint16List");
    for (int i = 0; i < list.length; i++)
      bd.setInt16(offset + i, list[i]);
  }

  /// Returns an [Uint8List] of length [lengthInBytes] from the current
  /// [wrIdx] in [bytes] and increments the [wrIdx] by [lengthInBytes].
  /// Throws an error if [wrIdx] is out of range.
  void writeUint16List(List<int> list) {
    for (int i = 0; i < list.length; i++)
      bd.setInt16(wrIdx + i, list[i]);
    wrIdx += list.length * 2;
  }

  /// Writes a signed 16-bit [int] at the [offset] in
  /// [bytes].  Throws an error if [wrIdx] is out of range.
  void setInt16(int offset, int value) {
    checkRange(offset, int16NBytes, 1, "setInt16");
    bd.setInt16(offset, value, endianness);
  }

  /// Returns an signed 16-bit [int] at [wrIdx] and increments
  /// the [wrIdx] by 2.
  void writeInt16(int value) {
    setInt16(wrIdx, value);
    wrIdx += 2;
  }

  /// Returns an [Int16List] of length [lengthInBytes]. [offset]
  /// is an absolute offset in [bytes].
  void setInt16List(int offset, List<int> list) {
    checkRange(offset, int16NBytes, list.length, "setInt16List");
    for (int i = 0; i < list.length; i++)
      bd.setInt16(wrIdx + i, list[i], endianness);
  }

  /// Returns an [Int16List] of length [lengthInBytes] from the current
  /// [wrIdx] in [bytes] and increments the [wrIdx] by [lengthInBytes].
  /// Throws an error if [wrIdx] is out of range.
  void writeInt16List(List<int> list) {
    setInt16List(wrIdx, list);
    wrIdx += list.length * int16NBytes;
  }

  void setUint32(int offset, int value) {
    checkRange(offset, uint32NBytes, 1, "Uint32");
    return bd.setUint32(offset, value, endianness);
  }

  /// writes a 32 bit unsigned integer from the byte array.
  void writeUint32(int value) {
    setUint32(wrIdx, value);
    wrIdx += 4;
  }

  /// Write a [Uint32List] at [offset] in [bytes].
  void setUint32List(int offset, List<int> list) {
    checkRange(offset, uint32NBytes, list.length, "setUint32List");
    for (int i = 0; i < list.length; i++)
      bd.setInt32(wrIdx + i, list[i], endianness);
  }

  /// Returns an [Uint32List] of length [lengthInBytes] from the current
  /// [wrIdx] in [bytes] and increments the [wrIdx] by [lengthInBytes].
  /// Throws an error if [wrIdx] is out of range.
  void writeUint32List(List<int> list) {
    setUint32List(wrIdx, list);
    wrIdx += list.length * uint32NBytes;
  }

  void setInt32(int offset, int value) {
    checkRange(offset, int32NBytes, 1, "Int32");
    bd.setInt32(offset, value, endianness);
  }

  /// writes a 32 bit signed integer from the byte array.
  void writeInt32(int value) {
    setInt32(wrIdx, value);
    wrIdx += int32NBytes;
  }

  /// Returns an [Int32List] of length [lengthInBytes]. [offset]
  /// is an absolute offset in [bytes].
  void setInt32List(int offset, List<int> list) {
    checkRange(offset, int32NBytes, list.length, "setInt32List");
    for (int i = 0; i < list.length; i++)
      bd.setInt32(wrIdx + i, list[i], endianness);
    wrIdx += list.length * int32NBytes;
  }

  /// Returns an [Int32List] of length [lengthInBytes] from the current
  /// [wrIdx] in [bytes] and increments the [wrIdx] by [lengthInBytes].
  /// Throws an error if [wrIdx] is out of range.
  void writeInt32List(List<int> list) {
    setUint32List(wrIdx, list);
    wrIdx += list.length * int32NBytes;
    ;
  }

  void setUint64(int offset, int value) {
    checkRange(offset, uint16NBytes, 1, "setUint64");
    bd.setUint64(offset, value, endianness);
  }

  /// writes a 32 bit unsigned integer from the byte array.
  void writeUint64(int value) {
    setUint64(wrIdx, value);
    wrIdx += 8;
  }

  /// Returns an [Uint64List] of length [lengthInBytes]. [offset]
  /// is an absolute offset in [bytes].
  void setUint64List(int offset, List<int> list) {
    checkRange(offset, uint64NBytes, list.length, "setUint64List");
    for (int i = 0; i < list.length; i++)
      bd.setInt64(wrIdx + i, list[i], endianness);
    wrIdx += list.length * uint64NBytes;
  }

  /// Returns an [Uint64List] of length [lengthInBytes] from the current
  /// [wrIdx] in [bytes] and increments the [wrIdx] by [lengthInBytes].
  /// Throws an error if [wrIdx] is out of range.
  void writeUint64List(List<int> list) {
    setUint64List(wrIdx, list);
    wrIdx += list.length * uint64NBytes;
  }

  void setInt64(int offset, int value) {
    checkRange(offset, 8, 8, "setInt64");
    bd.setInt64(offset, value, endianness);
  }

  /// writes a 32 bit signed integer from the byte array.
  void writeInt64(int value) {
    setInt64(wrIdx, value);
    wrIdx += int16NBytes;
  }

  /// Returns an [Int64List] of length [lengthInBytes]. [offset]
  /// is an absolute offset in [bytes].
  void setInt64List(int offset, List<int> list) {
    checkRange(offset, int16NBytes, list.length * int64NBytes, "setInt64List");
    for (int i = 0; i < list.length; i++)
      bd.setInt64(wrIdx + i, list[i], endianness);
    wrIdx += list.length * int16NBytes;
  }

  /// Returns an [Int64List] of length [lengthInBytes] from the current
  /// [wrIdx] in [bytes] and increments the [wrIdx] by [lengthInBytes].
  /// Throws an error if [wrIdx] is out of range.
  void writeInt64List(List<int> list) {
    setInt64List(wrIdx, list);
    wrIdx += list.length * int64NBytes;
  }

  void setFloat32(int offset, double value) {
    checkRange(offset, float32NBytes, 1, "setFloat32");
    bd.setFloat32(offset, value, endianness);
  }

  /// Synonym for setFloat32
  void setFLoat(int offset, double value) => setFloat32(offset, value);

  /// writes a 32 bit floating point number from the byte array.
  void writeFloat32(double value) {
    setFloat32(wrIdx, value);
    wrIdx += float32NBytes;
  }

  /// Synonym for writeFloat32
  void writeFloat(double value) => writeFloat32(value);

  /// Returns an [Float32List] of length [lengthInBytes]. [offset]
  /// is an absolute offset in [bytes].
  void setFloat32List(int offset, List<double> list) {
    checkRange(offset, float32NBytes, list.length, "setFloat32List");
    for (int i = 0; i < list.length; i++)
      bd.setFloat32(wrIdx + i, list[i], endianness);
    wrIdx += list.length * float32NBytes;
  }

  /// Returns an [Float32List] of length [lengthInBytes] from the current
  /// [wrIdx] in [bytes] and increments the [wrIdx] by [lengthInBytes].
  /// Throws an error if [wrIdx] is out of range.
  void writeFloat32List(List<double> list) {
    setFloat32List(wrIdx, list);
    wrIdx += list.length * float32NBytes;
  }

  /// Synonym for writeFloat32List
  void writeFloatList(List<double> list) => writeFloat32List(list);

  void setFloat64(int offset, double value) {
    checkRange(offset, float64NBytes, 1, "setFloat64");
    bd.setFloat64(offset, value, endianness);
  }

  /// writes a 64 bit floating point number from the byte array.
  void writeFloat64(double value) {
    setFloat64(wrIdx, value);
    wrIdx += float64NBytes;
  }

  /// Synonym for writeFloat64
  void writeDouble(double value) => writeFloat64(value);

  /// Returns an [Float64List] of length [lengthInBytes]. [offset]
  /// is an absolute offset in [bytes].
  void setFloat64List(int offset, List<double> list) {
    checkRange(offset, float32NBytes, list.length, "setFloat64List");
    for (int i = 0; i < list.length; i++)
      bd.setFloat32(wrIdx + i, list[i], endianness);
    wrIdx += list.length * float64NBytes;
  }

  /// Returns an [Float64List] of length [lengthInBytes] from the current
  /// [wrIdx] in [bytes] and increments the [wrIdx] by [lengthInBytes].
  /// Throws an error if [wrIdx] is out of range.
  void writeFloat64List(List<double> list) {
    setFloat64List(wrIdx, list);
    wrIdx += list.length * float64NBytes;
  }

  /// Synonym for writeFloat32List
  void writeDoubleList(List<double> list) => writeFloat64List(list);

  //TODO: Isn't there a faster way to do this? Should string trimming be done here?
  /*
  String setFixedString(int offset, int length) {
    checkRange(offset, length, 1, "FixedString");
    //var result = "";
    for(int i = offset; i < offset + length; i++) {
      int byte = bytes[i];
      if((byte == 0) || (byte == kBackslash)) {
        Uint8List charCodes = bytes.buffer.asUint8List(offset, i - offset);
        String s = new String.fromCharCodes(charCodes);
        //print('setFixedString1:"$s"');
        return s.trimRight();
      }
    }
    Uint8List charCodes = bytes.buffer.asUint8List(offset, length);
    String s = new String.fromCharCodes(charCodes);
    //print('setFixedString2:"$s"');
    return s.trimRight();
  }
  */
  //Enhancement: Which is better [setFixedString] or [setFixedString1]?  Does it matter?
  int setString(int offset, String s) {
    // Get Code Units first, because of multichar codeUnits in UTF-8
    Uint8List chars = s.codeUnits;
    checkRange(offset, stringNBytes, chars.length, "setString");
    for (int i = 0; i < chars.length; i++)
      bytes[offset + i] = chars[i];
    return chars.length;
  }

  /// Stores [String] as of 8 bit UTF-8 code points into [bytes].
  void writeString(String s) {
    wrIdx += setString(wrIdx, s);
  }

  //TODO: figure out the best default separator.
  /// Stores a [List<String>] into [bytes], with each [String] separated by [separator],
  /// and returns the number of UTF-8 code points stored.  [separator] can be 0 or more characters.
  int setStringList(int offset, List<String> list, [String separator = r"\"]) {
    //TODO: checkRange for enough space
    int nChars = 0;
    for (int i = 0; i < list.length; i++)
      nChars += setString(offset + i, list[i]);
    nChars += setString(nChars, separator);
    return nChars;
  }

  /// Stores a [List] of [String]s into [bytes] as UTF-8 code points.  The backslash (reverse solidus)
  /// code point is used to separate the [String]s.
  /// the [String]s.
  void writeStringList(List<String> list, [String separator = r"\"]) {
    wrIdx += setStringList(wrIdx, list, separator);
  }

  //TODO: If default [separator] above is not [r"\"], then move to DcmUint8_writer;
  // otherwise, delete the next two methods.
  /// Stores a [List<String>] into [bytes], with each [String] separated by [separator],
  /// and returns the number of UTF-8 code points stored.
  int setDcmStringList(int offset, List<String> list) {
    int nChars = 0;
    for (int i = 0; i < list.length; i++)
      nChars += setString(offset + i, list[i]);
    nChars += setString(nChars, r"\");
    return nChars;
  }

  //TODO: Move to DcmUint8_writer
  /// Stores a [List] of [String]s into [bytes].  The backslash (reverse solidus)
  /// characters separates the [String]s. [wrIdx] is incremented by the number of
  /// code points written.
  void writeDcmStringList(List<String> list) {
    wrIdx += setDcmStringList(wrIdx, list);
  }
}

