// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library service_handler;

import 'dart:io';
import 'package:logging/logging.dart';
import 'package:services/src/mirrors/utils.dart';
import 'package:services/src/serialization/json_serialization.dart';

final Logger _logger = new Logger('service_handler');

/**
 * Matches and handles [HttpRequests] and dispatches requests to methods of
 * [service].
 *
 * The matcher and handler work against request paths of the form
 * `path/methodName`. [path] is the URL path that the service is hosted at.
 * [matcher] matches any request starting with [path], and [handler] calls
 * the mathod on [service] matching the methodName.
 */
class ServiceHandler {
  Serializer serializer;
  final service;
  final String path;

  ServiceHandler(this.service, this.path, this.serializer);

  bool matcher(HttpRequest req) => req.path.startsWith(path);

  void handler(HttpRequest req, HttpResponse res) {
    // Add CORS headers
    res.headers.add("Access-Control-Allow-Origin", "*");
    res.headers.add("Access-Control-Allow-Headers", "Content-Type");
    res.headers.add("Access-Control-Allow-Headers", "Origin");
    if (req.headers.value("access-control-request-headers") != null) {
      // CORS preflight, return early
      res.outputStream.close();
      return;
    }
    if (!req.path.startsWith('$path/')) {
      res.statusCode = HttpStatus.NOT_FOUND;
    }
    var method = req.path.substring(path.length + 1);
    _logger.fine("method: $method");
    var sis = new StringInputStream(req.inputStream);
    var body = <String>[];
    sis.onLine = () => body.add(sis.readLine());
    sis.onClosed = () {
      var message = body.join('\n');
      _logger.fine("message: ${message}");
      if ((message == null) || (message.isEmpty)) {
        _logger.fine("no message");
        res.statusCode = HttpStatus.BAD_REQUEST;
        res.outputStream.close();
        return;
      }
      List args = serializer.deserialize(message);
      invoke(service, method, args).then((value) {
        _logger.fine("result: $value");
        res.statusCode = HttpStatus.OK;
        res.outputStream.writeString(serializer.serialize(value));
        res.outputStream.close();
      });
    };
  }
}
