// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library message;

abstract class Message {
  static const int INIT = 1;
  static const int INVOKE = 2;
  static const int REPLY = 3;

  static Map init() => {'id': INIT};

  static Map invoke(String method, String args) => {
    'id': INVOKE,
    'method': method,
    'args': args
  };

  static Map reply(String result) => {
    'id': REPLY,
    'result': result
  };
}
