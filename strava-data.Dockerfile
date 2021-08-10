FROM ruby:2.7-slim

USER root

RUN gem install bundler -v 2 && \
    bundle config --global frozen 1 && \
    apt-get update && \
    apt-get upgrade -yq && \
    apt-get install build-essential -y

COPY . .

RUN bundle install

USER 1001

CMD ["ruby", "analyzer.rb"]