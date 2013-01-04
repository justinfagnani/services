// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library server;

import 'dart:io';
import 'dart:uri';
import 'util.dart';
import 'package:logging/logging.dart';
import 'package:services/io/service_handler.dart';
import '../foo_service_impl.dart';

main() {
  Logger.root.level = Level.FINE;
  var server = new HttpServer();
  var fooHandler = new ServiceHandler(new FooServiceImpl(), '/foo');
  server.addRequestHandler(fooHandler.matcher, fooHandler.handler);
  server.defaultRequestHandler = serveFile;
  server.listen("127.0.0.1", 8888);
}
