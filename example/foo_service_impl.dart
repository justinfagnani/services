// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library foo_service_impl;

import 'foo_service.dart';

class FooServiceImpl extends FooService {
  Map<String, Foo> foos = new Map<String, Foo>();

  Future<Foo> getFoo(String id) {
    print("FooServiceImpl.getFoo called with id: $id");
    return new Future.immediate(foos[id]);
  }

  Future<bool> saveFoo(Foo foo) {
    print("FooServiceImpl.saveFoo called with foo: $foo");
    bool contains = foos.containsKey(foo.id);
    foos[foo.id] = foo;
    return new Future.immediate(!contains);
  }

  Future<Date> getDate() => new Future.immediate(new Date.utc(1976));
}
