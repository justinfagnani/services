// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library isolate_example;

import 'dart:isolate';
import 'dart:uri';
import 'package:services/isolate/service_proxy.dart';
import '../foo_service.dart';

class FooServiceProxy extends ServiceProxy implements FooService {
  FooServiceProxy(SendPort sendPort) : super(sendPort);
}

main() {
  // First, create a service hosted in an isolate. This probably would be done
  // separately in a real-world application.
  var sendPort = spawnUri('foo_host.dart');

  // Then, connect to the service.
  var fooService = new FooServiceProxy(sendPort);

  // Now we can use the service...
  fooService.getFoo("123").then((Foo foo) {
    print('getFoo("123"): $foo');
    var newFoo = new Foo.init("123", "Bob");
    fooService.saveFoo(newFoo).then((bool added) {
      print("saveFoo($newFoo): $added");
      fooService.getFoo("123").then((Foo foo) {
        print('getFoo("123"): $foo');
      });
    });
  });

}
