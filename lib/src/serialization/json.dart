// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library json;

import 'dart:async';
import 'dart:json';
import 'dart:math';
import 'package:logging/logging.dart';
import 'package:services/src/mirrors/mirrors.dart';
import 'package:services/src/mirrors/utils.dart';

import 'serialization.dart';

typedef String IdFunction(Object o);

var _random = new Random();
String _randomId(Object o) => _random.nextInt(4294967295).toString();

Logger _logger = new Logger('serializer');

abstract class CustomSerializer<T> {
  List<String> get typeNames;
  Map toMap(T o);
  T fromMap(Map m);
}

class DateSerializer extends CustomSerializer<Date> {
  final List<String> typeNames = [
    "dart:core.Date",
    "dart:coreimpl.DateImplementation",
  ];

  Map toMap(Date o) => {
    '__type': "dart:core.Date",
    'value': o.toString(),
  };

  Date fromMap(Map m) {
    return new Date.fromString(m['value']);
  }
}

/**
 * Serializes objects to JSON.
 *
 * Objects are converted to maps with a special property "__type" that contains
 * the qualified name of the Dart class.
 *
 * The first reference to an object is serialized inline. All subsequent
 * references are serialized as a map with a single property "__ref" containing
 * an id. When an object is referenced more than once it has an additional
 * property "__id".
 *
 * Only read/write public fields are serialized. Objects must have an unnamed,
 * no-arg constructor.
 *
 * TODO: references for lists.
 * TODO: expose the List/Map/simple type structure to use with isolates, rather
 * than just returning a string.
 * TODO: use some kind of identity map rather than HashMap
 */
class JsonSerializer extends Serializer {
  final IdFunction _idFunction;
  Map<String, CustomSerializer> _customSerializers = new Map<String, CustomSerializer>();

  JsonSerializer({List<CustomSerializer> customSerializers: const [], IdFunction idFunction})
      : _idFunction = (idFunction == null) ? _randomId : idFunction {
    customSerializers.forEach(_addCustomSerializer);
    _addCustomSerializer(new DateSerializer());
  }

  _addCustomSerializer(CustomSerializer s) {
    for (String typeName in s.typeNames) {
      _customSerializers[typeName] = s;
    }
  }

  String serialize(Object o) {
    var str = stringify(_serialize(o, new LinkedHashMap()));
//    print("serialized: $str");
    return str;
  }

  Object deserialize(String json) {
    return _deserialize(parse(json), new LinkedHashMap());
  }

  _serialize(var o, Map<Object, Map> visited) {
    if ((o == null) ||
        (o is num) ||
        (o is bool) ||
        (o is String)) {
      return o;
    } else if (o is Map) {
      return _serializeMap(o, visited);
    } else if (o is List) {
      return _serializeList(o, visited);
    } else {
      return _serializeObject(o, visited);
    }
  }

  _serializeObject(var o, Map<Object, Map>  visited) {
    if (visited.containsKey(o)) {
      _logger.fine("previously visited object: $o");
      return _ref(o, visited);
    }
    var mirror = reflect(o);
    var classMirror = mirror.type;
    var typeName = classMirror.qualifiedName;
    Map serialized;
    if (_customSerializers.containsKey(typeName)) {
      serialized = _customSerializers[typeName].toMap(o);
      visited[o] = serialized;
    } else {
      serialized = new LinkedHashMap();
      serialized["__type"] = classMirror.qualifiedName;
      visited[o] = serialized;
      for (var m in classMirror.variables.keys) {
        _logger.fine("member: $m");
        var value =  deprecatedFutureValue(mirror.getField(m));
        _logger.fine("value: $value");
        serialized[m] = _serialize(value.reflectee, visited);
      }
    }
    return serialized;
  }

  _serializeMap(Map map, Map<Object, Map>  visited) {
    if (visited.containsKey(map)) {
      _logger.fine("previously visited map: $map");
      return _ref(map, visited);
    }
    Map serialized = new LinkedHashMap();
    visited[map] = serialized;
    for (var k in map.keys) {
      serialized[_serialize(k, visited)] = _serialize(map[k], visited);
    }
    return serialized;
  }

  _serializeList(List list, Map<Object, Map>  visited) {
//    if (visited.containsKey(list)) {
//      _logger.fine("previously visited list: list");
//      return _ref(list, visited);
//    }
    List serialized = new List();
//    visited[list] = serialized;
    for (var i in list) {
      serialized.add(_serialize(i, visited));
    }
    return serialized;
  }

  Map _ref(Object o, Map<Object, Map>  visited) {
    Map serialized = visited[o];
    String ref = serialized["__id"];
    if (ref == null) {
      ref = _idFunction(o);
      serialized["__id"] = ref;
    }
    return {"__ref": ref};
  }

  dynamic _deserialize(dynamic o, Map<String, Object> refs) {
    if ((o == null) ||
        (o is num) ||
        (o is bool) ||
        (o is String)) {
      return o;
    } else if (o is List) {
      var list = [];
      for (var i in o) {
        list.add(_deserialize(i, refs));
      }
      return list;
    } else if (o is Map) {
      if (o.containsKey( "__ref")) {
        return refs[o["__ref"]];
      } else if (o.containsKey("__type")) {
        var typeName = o["__type"];
        return _deserializeObject(o, refs);
      } else { // map
        var map = {};
        for (var k in o.keys) {
          map[_deserialize(k, refs)] = _deserialize(o[k], refs);
        }
        return map;
      }
    }
  }

  Object _deserializeObject(Map map, Map<String, Object> refs) {
    var typeName = map["__type"];
    if (_customSerializers.containsKey(typeName)) {
      return _customSerializers[typeName].fromMap(map);
    }
    var classMirror = getClassMirror(typeName);
    var objMirror = deprecatedFutureValue(classMirror.newInstance("", []));

    // if the map has an '__id' key, the object is referenced later
    // store the instance in refs
    if (map.containsKey('__id')) {
      refs[map['__id']] = objMirror.reflectee;
    }

    for (var fieldName in map.keys) {
      if (!fieldName.startsWith("__")) {
        var value = _deserialize(map[fieldName], refs);
        objMirror.setField(fieldName, reflect(value));
      }
    }
    return objMirror.reflectee;
  }

  MethodMirror _getDefaultConstructor(ClassMirror m) {
    var ctor = m.constructors[""];
    // TODO(justinfagnani): allow optional parameters
    if (!ctor.parameters.isEmpty) {
      throw "Can't deserialize ${m.qualifiedName}";
    }
    return ctor;
  }
}