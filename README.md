services
========

The services package attempts to provide an easy-to-use abstraction for using
isolates based on "service interfaces".

It is currently a proof of concept that relies on mirrors for serialization and
for invoking service implementation methods, so it is not suitable for use in
the browser. A future version of the package, hopefully with a better name, will
likely use code generation so that it does not rely on mirrors.
