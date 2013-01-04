services
========

The services package attempts to provide an easy-to-use abstraction for using
isolates based on "service interfaces". It is currently a proof of concept that
relies on mirrors for serialization and for invoking service implementation
methods, so it is not suitable for use in the browser. A future version of the
package, hopefully with a better name, will likely use code generation so that
it does not rely on mirrors.

Architecture
============

A service is composed of two parts: the interface and the implementation. The
service interface is an abstract class that only defines async methods, those
that return `Futures`. The implementation simply implements the interface.

A sample service interface for a date service:

abstract class TimeService {
  Future<Date> getDate
}

And the implementation:

class TimeServiceImpl implements TimeService {
  Future<Date> getDate => new Future.immediate(new Date.now());
}

The implementation is hosted in an isolate or separate VM. The interface is used
to call the service via ServiceProxy objects. Arguments and return values are
serialized.

There are two helper objects to host implementations. `ServiceHost` hosts a
service implementation in an isolate, and communicates to proxies via a
`ReceivePort`. `ServiceHandler` hosts a service implementation on a server and
communicates to proxies via HTTP.

There are three `ServiceProxy` implementations. One communicates via `SendPorts`
for use with a `ServiceHost`, and the other two use HTTP, either from dart:io
or dart:html, for use with a `ServiceHandler`.