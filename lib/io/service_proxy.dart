// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library service_proxy;

import 'dart:io';
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
    new HttpClient().getUrl(new Uri('$url/$method'))
      ..onRequest = (req) {
        req.contentLength = message.length;
        req.outputStream
          ..writeString(message)
          ..close();
      }
      ..onResponse = (HttpClientResponse res) {
        var lines = <String>[];
        var sis = new StringInputStream(res.inputStream);
        sis.onLine = () => lines.add(sis.readLine());
        sis.onClosed = () {
          var result = Strings.join(lines, '\n');
          completer.complete(_serializer.deserialize(result));
        };
      }
      ..onError = (e) => completer.completeException(e);
    return completer.future;
  }
}
