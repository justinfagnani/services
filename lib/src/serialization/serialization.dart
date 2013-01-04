// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/**
 * This library provides a simple JSON serializer. It should soon be replaced
 * with the serialization package in the SDK.
 *
 * TODO(justinfagnani): Should use pkg/serialization. Might need to change how
 * messages are structured to know the type of response before deserialization,
 * since pkg/serialization needs rules to be added before it can
 * serialize/deserialize.
 */
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
