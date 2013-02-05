// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library foo_service;

import 'dart:async';
import 'package:services/src/serialization/json_serialization.dart';

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

class FooSerializer extends JsonSerializer {
  FooSerializer() {
    // We expect all Foo services to use the same rules, and we want this to
    // work without requiring reflection, and to minimize space, so we turn
    // off sending the rules along with the data. If the client and the server
    // do disagree about the exact rules being used, this will fail.
    serialization.selfDescribing == false;
  }
  get myRules => [new FooRule()];
}

class FooRule extends CustomRule {
  bool appliesTo(x, _) => x is Foo;
  List getState(Foo x) => [x.id, x.name, x.child];
  Foo create(List state) => new Foo.init(state.first, state[1]);
  void setState(Foo instance, List state) => instance.child = state[2];
}