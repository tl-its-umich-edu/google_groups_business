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


#ADD ./GGB-CPM-Dev-3bc39c2ec7f7.json .
RUN mkdir -p /Users/dlhaines/dev/BITBUCKET/GoogleAPIDemo/discussions-dev


WORKDIR /app

# expose the port and run the server.
EXPOSE  9292
#CMD rackup --host 0.0.0.0 -p 9292

# example
#CMD cp /usr/share/ocellus/settings.py ./hacks_mbof/; python manage.py migrate;./runAsUser.sh bjensen

## now lists
#CMD ls -l /usr/local/config/default/*; ls -l /usr/local/config/cred/*; rackup --host 0.0.0.0 -p 9292
#CMD thin start -R config.ru -p 3000
#CMD cp /usr/local/config/default/default.yml /app; cp /usr/local/config/cred/ggb-cpm-dev-3bc39c2ec7f7.json /Users/dlhaines/dev/BITBUCKET/GoogleAPIDemo/discussions-dev/GGB-CPM-Dev-3bc39c2ec7f7.json; rackup --host 0.0.0.0 -p 9292
CMD cp /usr/local/config/default/default.yml /app; cp /usr/local/config/cred/ggb-cpm-dev-3bc39c2ec7f7.json /Users/dlhaines/dev/BITBUCKET/GoogleAPIDemo/discussions-dev/GGB-CPM-Dev-3bc39c2ec7f7.json; thin start -R config.ru --address 0.0.0.0 --port 9292

#CMD rake 
#CMD rackup
#CMD /bin/bash

### end