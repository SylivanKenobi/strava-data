FROM quay.io/aptible/ruby:2.7-debian

RUN bundle config --global frozen 1 && \
    apt-get update && \
    apt-get upgrade -yq

COPY . .

USER 1001

RUN bundle install

CMD ["ruby", "analyzer.rb"]