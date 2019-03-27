FROM ruby:2.5.3

ADD . /knative-assistant-action-spotify
WORKDIR /knative-assistant-action-spotify

RUN bundle install

EXPOSE 8080
ENTRYPOINT ["bundle", "exec", "ruby", "server.rb"]