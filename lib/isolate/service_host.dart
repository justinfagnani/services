// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library service_host;

import 'dart:isolate';
import 'package:services/src/mirrors/utils.dart';
import 'package:services/src/serialization/json.dart';
import 'package:services/src/serialization/serialization.dart';
import 'message.dart';

/**
 * Hosts a service on a [ReceivePort]
 */
class ServiceHost {
  final service;
  ReceivePort _port;

  ServiceHost(this.service);

  void listen({ReceivePort receivePort}) {
    if (_port != null) throw new StateError('already listening');
    _port = (receivePort == null) ? port : receivePort;
    var serializer = new JsonSerializer();
    port.receive((msg, replyTo) {
      switch (msg['id']) {
        case Message.INVOKE:
          var method = msg['method'];
          var args = serializer.deserialize(msg['args']);
          invoke(service, method, args).then((value) {
            var result = serializer.serialize(value);
            replyTo.send(Message.reply(result));
          });
          break;
        default:
          print("unknown message type");
          break;
      }
    });
  }

  close() {
    if (_port == null) throw new StateError('not listening');
    _port.close();
    _port = null;
  }
}
