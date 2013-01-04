// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library json_serializer_test;

import 'dart:json';
import 'dart:math';
import 'package:services/src/mirrors/mirrors.dart';
import 'package:services/src/serialization/json.dart';
import 'package:services/src/serialization/serialization.dart';
import 'package:unittest/unittest.dart';

main() {
  var serializer;

  setUp(() {
    serializer = new JsonSerializer();
  });

  test("simple types", () {
    expect(serializer.deserialize('"Test"'), "Test");
    expect(serializer.deserialize('1'), 1);
    expect(serializer.deserialize('1.0'), 1.0);
    expect(serializer.deserialize('true'), true);
    expect(serializer.deserialize('false'), false);
    expect(serializer.deserialize('null'), null);
  });

  test("list", () {
    expect(serializer.deserialize('[1, 2, 3]'), [1, 2, 3]);
  });

  test("map", () {
    expect(serializer.deserialize('{"a":1,"b":2}'), {"a":1,"b":2});
  });

  test("simple object", () {
    Foo foo = new Foo()
      ..name = "Bob"
      ..age = 29;
    expect(
        serializer.deserialize('{"__type":"json_serializer_test.Foo","name":"Bob","age":29}'),
        foo);
  });

  test("cycle", () {
    Ref expected = new Ref()
      ..name = "Bob";
    expected.self = expected;
    expect(serializer.deserialize('''{
          "__type":"json_serializer_test.Ref",
          "__id":"12345",
          "name":"Bob",
          "self": {"__ref":"12345"}
        }'''),
        expected);
  });
}

class Foo {
  String name;
  int age;
  bool operator ==(o) => (identical(o, this)) || (name == o.name) && (age == o.age);
}

class Ref {
  String name;
  Ref self;
  bool operator ==(o) => (identical(o, this)) || (name == o.name) && (self.name == o.self.name);
}
