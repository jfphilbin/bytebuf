//TODO: copyright

import 'dart:typed_data';

import 'package:byte_array/bytes_buf.dart';
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