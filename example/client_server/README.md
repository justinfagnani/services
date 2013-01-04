The services/client_server examples shows how to serve and use services over
HTTP. There is one service server, which runs on the standalone VM, and two
clients: a standalone and a Dartium version.

How To Run
==========

To run the server, execute:

    cd services/
    dart example/client_server/server.dart

To run the standalone client, execute:

    dart example/client_server/client.dart

It will automatically connect to the server.

To Run the Dartium-based client, open Dartium and navaigate to:

http://127.0.0.1:8888/example/client_server/browser_client.html

or launch browser_client.html from the Dart Editor.


Files
=====

../foo_service.dart

The interface for a simple service called FooService, and declaration of
a class Foo that's serialized as an argument and return value to FooService.


../foo_service_impl.dart

The implementation of FooService


server.dart

A simple web server that uses a ServiceHandler to serve requests to the
FooService.


client.dart

A simple standalone client that calls a few methods on FooService to
test and demonstrate invocation over dart:io.HttpClient and serialization.


browser_client.dart

A browser-based client that performs the same operations as client.dart
but uses a dart:html.HttpClient based transport.
