// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library server;

import 'dart:io';

main() {
  var server = new HttpServer();
  server.addRequestHandler((r) => r.path == '/makeServiceSource', (req, res) {
    var className = req.queryParameters['className'];
    var libraryUri = req.queryParameters['libraryUri'];
    res.outputStream.writeString("""
main() {
  print("woot!");
}
""");
    res.outputStream.close();
  });
  server.listen("127.0.0.1", 8888);
}
