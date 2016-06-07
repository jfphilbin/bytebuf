// Copyright (c) 2016, Open DICOMweb Project. All rights reserved.
// Use of this source code is governed by the open source license
// that can be found in the LICENSE file.
// Author: Jim Philbin <jfphilbin@gmail.edu>
// See the AUTHORS file for other contributors.

import 'dart:typed_data';

import 'package:byte_buf/byte_buf.dart';
import "package:test/test.dart";

import 'test_utilities.dart';

String magicAsString = "DICOM-MD";
Uint8List magic = magicAsString.codeUnits;

void main() {
  test("Read MetadataFile Magic value", () {
    var s = "DICOM-MD";
    //List<int> cu = s.codeUnits;
    //print('code units = $cu');
    Uint8List list = toUtf8(s);
    print('utf8= $list');
    //var list = new Uint8List.fromList(cu);
    print('list= $list');
    var reader = new ByteBufReader(list);
    String name = reader.readString(8);
    print('name= "$name"');
    expect(name, equals("DICOM-MD"));
  });
  /*
  test("String.trim() removes surrounding whitespace", () {
    var string = "  foo ";
    expect(string.trim(), equals("foo"));
  });
  */
}