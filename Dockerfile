# Docker configuration for of GGB microservice
#### docker commands: 
# build container ->  docker build -t ggba .
# run container   ->  docker run -p 9292:9292 -it ggba
####################
# TTD:
# - dns name from outside
# - openshift
# - build ping url for the container? (maybe wrong idea for docker?)
# - rake vs explicit startup.
# - credentials: docker vs openshift vs laptop.
# - minimize container?
# - logging
# - monitoring
####################

FROM ruby:2.2

RUN apt-get update && apt-get install git -y

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD . $APP_HOME
RUN bundle install

## Add credentials (will be different in openshift)
## local: copy in credentials to local directory
RUN mkdir -p /Users/dlhaines/dev/BITBUCKET/GoogleAPIDemo/discussions-dev
WORKDIR /Users/dlhaines/dev/BITBUCKET/GoogleAPIDemo/discussions-dev
# ADD must be relative to the Dockerfile directory
ADD ./GGB-CPM-Dev-3bc39c2ec7f7.json .
WORKDIR /app

# expose the port and run the server.
EXPOSE  9292
CMD rackup --host 0.0.0.0 -p 9292

#CMD rake 
#CMD rackup
#CMD /bin/bash

### end