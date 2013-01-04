// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library client;

import 'dart:uri';
import 'package:services/io/service_proxy.dart';
import '../foo_service.dart';

class ClientFooService extends ServiceProxy implements FooService {
  ClientFooService() : super('http://127.0.0.1:8888/foo');
}

void main() {
  FooService fooService = new ClientFooService();
  print("");
  fooService.getFoo("123").then((foo) {
    print('getFoo("123"): $foo');
    var newFoo = new Foo.init("123", "Bob");
    fooService.saveFoo(newFoo).then((added) {
      print("saveFoo($newFoo): $added");
      fooService.getFoo("123").then((foo) {
        print('getFoo("123"): $foo');
      });
    });
  });

  var child = new Foo.init("2", "child");
  var parent = new Foo.init("1", "parent", child);
  fooService.saveFoo(parent).then((added) {
    print(added);
  });
}
