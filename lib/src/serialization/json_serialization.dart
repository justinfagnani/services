// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/**
 * This library provides serialization for service messages and arguments.
 * It provides an abstract class [Serializer] and a subclass
 * [JsonSerializer] for putting the data into a form easily transmittable over
 * Json. A particular service may want to provide its own subclass that will
 * specify particular [SerializationRule]s, or may rely on reflection to have
 * the rules automatically added.
 */
library json_serialization;

import 'package:serialization/serialization.dart';
export 'package:serialization/serialization.dart' show CustomRule;
import 'dart:json' as json;

abstract class Serializer {
  String serialize(Object o);
  Object deserialize(String s);
}

class JsonSerializer extends Serializer {
  Serialization serialization = new Serialization();
  Format format = new SimpleFlatFormat();
  // We can change this to use a format that's easier to read and less verbose
  // for simple examples.
  //  Format format = new SimpleJsonFormat(storeRoundTripInfo: true);

  JsonSerializer() {
    addRules(myRules);
  }

  String serialize(object) {
    var serialized = serialization.write(object, format);
    return json.stringify(serialized);
  }

  deserialize(String jsonString) {
    var result = serialization.newReader(format).
        read(json.parse(jsonString));
    return result;
  }

  void addRules(List newRules) {
    newRules.forEach(serialization.addRule);
  }

  List get myRules => [];
}