This is a simple microservices example that uses Ruby + Sinatra to provide a simple Products Service.
Test GIT CONFIG

== Docker ==

To run with local Docker:

* startup Docker container application

* build your container with:

docker build -t ggba . -f Dockerfile.local

or

docker build - < Dockerfile.local


* start container  with:

docker run -p 9292:9292 -it ggba

The dockerfile, port, and tag may vary.  Dockerfile.local is a version
that deals with the fact that the local Docker doesn't have the
Openshift credentials facility.
