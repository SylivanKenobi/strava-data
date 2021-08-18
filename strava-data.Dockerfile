FROM ruby:2.7-slim

USER root

RUN gem install bundler -v 2 && \
    bundle config --global frozen 1 && \
    apt-get update && \
    apt-get upgrade -yq && \
    apt-get install build-essential -y

WORKDIR app-src

COPY Gemfile.lock .
COPY Gemfile .

RUN bundle install

COPY . .

USER 1001

CMD ["ruby", "analyzer.rb"]