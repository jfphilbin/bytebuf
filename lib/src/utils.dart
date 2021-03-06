// Copyright (c) 2016, Open DICOMweb Project. All rights reserved.
// Use of this source code is governed by the open source license
// that can be found in the LICENSE file.
// Author: Jim Philbin <jfphilbin@gmail.edu>
// See the AUTHORS file for other contributors.

import 'dart:typed_data';

//TODO: figure out better names for these
//TODO: replace these with the Integer constants.

// Constants for [length] of ByteData types.
const kByteLength = 1;
const kUtf8NBytes = 1;
const kUtf16NBytes = 2;
const kInt8NBytes = Int8List.BYTES_PER_ELEMENT;
const kUint8NBytes = Uint8List.BYTES_PER_ELEMENT;
const kInt16NBytes = Int16List.BYTES_PER_ELEMENT;
const kUint16NBytes = Uint16List.BYTES_PER_ELEMENT;
const kInt32NBytes = Int32List.BYTES_PER_ELEMENT;
const kUint32NBytes = Uint32List.BYTES_PER_ELEMENT;
const kInt64NBytes = Int64List.BYTES_PER_ELEMENT;
const kUint64NBytes = Uint64List.BYTES_PER_ELEMENT;
const kFloat32NBytes = Float32List.BYTES_PER_ELEMENT;
const kFloat64NBytes = Float64List.BYTES_PER_ELEMENT;

///
int checkView(ByteBuffer buffer, int offset, int length) {
  length = (length == null) ? buffer.lengthInBytes : length;
  int end = offset + length;
  print('buffer length: ${buffer.lengthInBytes}');
  print('isNotValid= ${_isNotValid(buffer, offset, end)}');
  if (_isNotValid(buffer, offset, end))
    throw new ArgumentError("Invalid Indices into buffer: "
        "bytes = $buffer, offset = $offset, length = $length");
  return end;
}

int checkSublist(ByteBuffer buffer, int start, int end) {
  end = (end == null) ? buffer.lengthInBytes : end;
  if (_isNotValid(buffer, start, end))
    throw new ArgumentError("Invalid Indices into buffer: "
        "bytes = $buffer, start = $start, end = $end");
  return end;
}

// *** should only be called by _checkView or _checkSublist ***
bool _isNotValid(ByteBuffer buffer, int start, int end) =>
    ((start < 0) || (end < start) || (end > buffer.lengthInBytes));
