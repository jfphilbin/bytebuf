// Copyright (c) 2016, Open DICOMweb Project. All rights reserved.
// Use of this source code is governed by the open source license
// that can be found in the LICENSE file.
// Author: Jim Philbin <jfphilbin@gmail.edu>
// See the AUTHORS file for other contributors.
library odw.sdk.utilities.bytebuf.test.utilities;

import 'dart:convert';
import 'dart:typed_data';

import 'package:bytebuf/bytebuf_reader.dart';

Uint8List toUtf8(String s) => UTF8.encode(s);

String StringFromBytes(Uint8List bytes) => UTF8.decode(bytes);

ByteBufReader readerFromString(String s) {
  return new ByteBufReader(toUtf8(s));
}

