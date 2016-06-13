// Copyright (c) 2016, Open DICOMweb Project. All rights reserved.
// Use of this source code is governed by the open source license
// that can be found in the LICENSE file.
// Author: Jim Philbin <jfphilbin@gmail.edu>
// See the AUTHORS file for other contributors.
library odw.sdk.utilities.bytebuf.utils;

import 'dart:typed_data';

//TODO: rename to Uint8Buffer (or Uint8Reader, Uint8Writer, Uint8Buffer)
//TODO: add write functionality

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
