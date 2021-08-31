FROM ruby:2.7-alpine

USER root

RUN gem install bundler -v 2 && \
    bundle config --global frozen 1 && \
    apk update && \
    apk upgrade && apk add --upgrade build-base

WORKDIR app-src

COPY Gemfile.lock .
COPY Gemfile .

RUN bundle install

COPY . .

USER 1001

CMD ["ruby", "analyzer.rb"]