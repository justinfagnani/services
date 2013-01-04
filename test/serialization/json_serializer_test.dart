// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library json_serializer_test;

import 'dart:json';
import 'dart:math';
import 'package:services/src/mirrors/mirrors.dart';
import 'package:services/src/serialization/serialization.dart';
import 'package:services/src/serialization/json.dart';
import 'package:unittest/unittest.dart';

main() {
  var serializer;

  setUp(() {
    serializer = new JsonSerializer();
  });

  test("simple types", () {
    expect(serializer.serialize("Test"), '"Test"');
    expect(serializer.serialize(1), '1');
    expect(serializer.serialize(1.0), '1.0');
    expect(serializer.serialize(true), 'true');
    expect(serializer.serialize(false), 'false');
    expect(serializer.serialize(null), 'null');
  });

  test("list", () {
    expect(serializer.serialize([1, 2, 3]), "[1,2,3]");
  });

  test("map", () {
    expect(serializer.serialize({'a': 1, 'b':2}), '{"a":1,"b":2}');
  });

  test("simple object", () {
    Foo foo = new Foo()
      ..name = "Bob"
      ..age = 29;
    expect(
        JSON.parse(serializer.serialize(foo)),
        {"__type":"json_serializer_test.Foo","name":"Bob","age":29});
  });

  test("cycle", () {
    serializer = new JsonSerializer(idFunction: (o) => "12345");
    Ref ref = new Ref()
      ..name = "Bob";
    ref.self = ref;
    var json = serializer.serialize(ref);
    expect(
        JSON.parse(json),
        {
          "__type":"json_serializer_test.Ref",
          "__id":"12345",
          "name":"Bob",
          "self": {"__ref":"12345"},
        });
  });
}

class Foo {
  String name;
  int age;
}

class Ref {
  String name;
  Ref self;
}

