// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library foo_service;

class Foo {
  String id;
  String name;
  Foo child;
  Foo();
  Foo.init(this.id, this.name, [Foo this.child]);
  String toString() => "Foo {id: $id, name: $name, child: $child}";
}

abstract class FooService {
  Future<Foo> getFoo(String id);
  Future<bool> saveFoo(Foo foo);
  Future<Date> getDate();
}
