// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library service_proxy;

import 'dart:html';
import 'dart:uri';
import 'package:logging/logging.dart';
import 'package:services/src/serialization/json.dart';
import 'package:services/src/serialization/serialization.dart';

final Logger _logger = new Logger('service_proxy');

/**
 * A service proxy that sends service calls over HTTP.
 * The receiving server must be running a service via a [ServiceHandler].
 */
class ServiceProxy {
  final Serializer _serializer;
  final String url;

  ServiceProxy(String this.url, {Serializer serializer})
      : _serializer = (serializer == null) ? new JsonSerializer() : serializer;

  noSuchMethod(InvocationMirror im) {
    // TODO(justinfagnani): validate method, make sure it's async
    var completer = new Completer();
    var method = im.memberName;
    var message = _serializer.serialize(im.positionalArguments);
    var req = new HttpRequest();
    req..on.loadEnd.add((e) {
        var response = req.responseText;
        completer.complete(response);
      })
      ..on.error.add((HttpRequestProgressEvent e) {
        print("error: ${e.type}");
      })
      ..open("POST", '$url/$method', true)
      ..send(message);
    return completer.future;
  }
}
