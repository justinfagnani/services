// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library browser_client;

import 'dart:html';
import 'dart:uri';
import '../foo_service.dart';
import 'package:services/html/service_proxy.dart';

class ClientFooService extends ServiceProxy implements FooService {
  ClientFooService() : super('http://127.0.0.1:8888/foo', new FooSerializer());
}

void main() {
  PreElement container = query('pre#container');
  FooService fooService = new ClientFooService();
  fooService.getFoo("123").then((foo) {
    container.appendText('getFoo("123"): $foo\n');
    var newFoo = new Foo.init("123", "Bob");
    fooService.saveFoo(newFoo).then((added) {
      container.appendText("saveFoo($newFoo): $added\n");
      fooService.getFoo("123").then((foo) {
        container.appendText('getFoo("123"): $foo\n');
      });
    });
  });
}
