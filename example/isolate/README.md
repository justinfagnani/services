The isoate example shows how to use services via isolates. There is only one
file to run, which spawns an isolate and communicates with it via a service
interface.

How To Run
==========

cd services/
dart example/isolate/isolate_example.dart

Files
=====

../foo_service.dart

The interface for a simple service called FooService, and declaration of
a class Foo that's serialized as an argument and return value to FooService.


../foo_service_impl.dart

The implementation of FooService


isolate_example.dart

The main example source. Creates an isolate hosting a FooServiceImpl,
the a client proxy, and then calls the proxy.


foo_host.dart

A file that simply creates a FooServiceImpl and hosts it. This file will
ideally be unnecessary if we can call spawnUri() with a data: URI or
add a function like spawnScript(String script).