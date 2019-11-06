# OPtimized for Heroku.com (a salesforce company)


FROM ruby:2.6.4
# FROM nning2/truffleruby:latest
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

RUN apt-get install -y libproj-dev
RUN apt-get install -y libgeos-dev
RUN apt-get install -y graphviz
RUN apt-get install -y graphviz-dev
# RUN apt-get install -y elasticsearch
# RUN apt-get install -y elasticsearch-dev

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt update &&  apt install yarn


RUN mkdir /myapp
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install

COPY . /myapp

RUN rails db:migrate

# how to make the following line idempotent?
RUN rails db:seed
RUN rails runner "Comment.reindex"
RUN rails runner "EziiCity.reindex"


RUN RAILS_ENV=production rails assets:precompile


RUN rm -f /myapp/tmp/pids/server.pid
# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
# EXPOSE 3000

# Start the main process.
CMD rails server -b 0.0.0.0 -e production
# TODO: PORT is set in entrypoint, that's hacky, but couldn't find a differen way for heroku
