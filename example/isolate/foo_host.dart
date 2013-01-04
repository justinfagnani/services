// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library foo_host;

import 'package:services/isolate/service_host.dart';
import '../foo_service_impl.dart';

// This file should be generated, but spawnUri() does not work with
// data: URIs
main() {
  new ServiceHost(new FooServiceImpl()).listen();
}
