// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library utils;

import 'dart:async';
import 'mirrors.dart';

Future invoke(obj, String method, List args) {
  var completer = new Completer();
  var mirror = reflect(obj);
  var methodMirror = getMethodMirror(mirror.type, method);
  if (methodMirror != null) {
    mirror.invoke(method, args.mappedBy(reflect).toList()).then((im) {
      if (im.reflectee != null) {
        im.reflectee.then((value) {
          completer.complete(value);
        });
      } else {
        completer.complete(null);
      }
    });
  } else {
    // TODO: throw exception?
    completer.complete(null);
  }
  return completer.future;
}

ClassMirror getClassMirror(String qualifiedName) {
  var lib = qualifiedName.substring(0, qualifiedName.indexOf("."));
  var type = qualifiedName.substring(qualifiedName.indexOf(".") + 1);
  var libMirror = currentMirrorSystem().libraries[lib];
  return libMirror.classes[type];
}

/**
 * Walks up the class hierarchy to find a method declaration with
 * the given [name].
 *
 * Note that it's not possible to tell if there's an implementation
 * due to noSuchMethod().
 */
MethodMirror getMethodMirror(ClassMirror classMirror, String name) {
  assert(classMirror != null);
  assert(name != null);
  if (classMirror.methods[name] != null) {
    return classMirror.methods[name];
  }
  if (hasSuperclass(classMirror)) {
    var methodMirror = getMethodMirror(classMirror.superclass, name);
    if (methodMirror != null) {
      return methodMirror;
    }
  }
  for (ClassMirror supe in classMirror.superinterfaces) {
    var methodMirror = getMethodMirror(supe, name);
    if (methodMirror != null) {
      return methodMirror;
    }
  }
  return null;
}

/**
 * Work-around for http://dartbug.com/5794
 */
bool hasSuperclass(ClassMirror classMirror) {
  ClassMirror superclass = classMirror.superclass;
  return (superclass != null)
      && (superclass.qualifiedName != "dart:core.Object");
}

/**
 * Walks the class hierarchy to search for [qualifiedName].
 */
bool implements(ClassMirror m, String qualifiedName) {
  if (m == null) return false;
  if (m.qualifiedName == qualifiedName) return true;
  if (m.qualifiedName == "dart:core.Object") return false;
  if (implements(m.superclass, qualifiedName)) return true;
  for (ClassMirror i in m.superinterfaces) {
    if (implements(i, qualifiedName)) return true;
  }
  return false;
}
