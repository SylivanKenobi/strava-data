FROM ruby:2.7

RUN bundle config --global frozen 1 && \
    apt-get update && \
    apt-get upgrade -yq

COPY . .

RUN bundle install

USER 1001

CMD ["ruby", "analyzer.rb"]