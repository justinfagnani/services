// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library serialization;

import 'dart:json';
import 'dart:math';
import 'package:logging/logging.dart';
import 'package:services/src/mirrors/mirrors.dart';
import 'package:services/src/mirrors/utils.dart';

const _SIMPLE_TYPES = const [
  "dart:core.bool",
  "dart:core.num",
  "dart:core.int",
  "dart:core.double",
  "dart:core.String",
  "dart:coreimpl.String",
];

abstract class Serializer {
  String serialize(Object o);
  Object deserialize(String s);
}
