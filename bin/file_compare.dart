// Copyright (c) 2016, Open DICOMweb Project. All rights reserved.
// Use of this source code is governed by the open source license
// that can be found in the LICENSE file.
// Author: Jim Philbin <jfphilbin@gmail.edu> - 
// See the AUTHORS file for other contributors.

import 'dart:io';
import 'dart:typed_data';

import 'package:args/args.dart';

import 'package:bytebuf/bytebuf.dart';

void main(List<String> args) {


  // var compare = new FileCompare(path1, path2);




}

String fileCompare(String path1, String path2) {
  File f1 = new File(path1);
  File f2 = new File(path2);

  Uint8List bytes1 = f1.readAsBytesSync();
  Uint8List bytes2 = f2.readAsBytesSync();

  return compareBytes(bytes1, bytes2);
}