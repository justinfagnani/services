// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library util;

import 'dart:io';

final _cwd = new Directory.current().path;

/// Very simple async static file server
void serveFile(HttpRequest req, HttpResponse resp) {
  Path path = new Path.fromNative(req.path).canonicalize();
  path = new Path("$_cwd$path");
  if (path.hasTrailingSeparator) {
    path = path.append("index.html");
  }
  print("Service file: ${path.toNativePath()}");
  File file = new File(path.toNativePath());
  file.exists().then((bool exists) {
    if (exists) {
      file.readAsString().then((String text) {
        resp.headers.set(HttpHeaders.CONTENT_TYPE, _getContentType(file));
        resp.outputStream.writeString(text);
        resp.outputStream.close();
      });
    } else {
      print('not found');
      resp.statusCode = HttpStatus.NOT_FOUND;
      resp.outputStream.close();
    }
  });
}

Map<String, String> _contentTypes = const {
  "html": "text/html; charset=UTF-8",
  "dart": "application/dart",
  "css": "text/css",
  "js": "application/javascript",
};

String _getContentType(File file) => _contentTypes[file.name.split('.').last];

String _stripParent(String path) =>
    (path.startsWith('../')) ? _stripParent(path.substring(3)) : path;
