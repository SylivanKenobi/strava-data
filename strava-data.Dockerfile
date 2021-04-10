FROM ruby:2.7

RUN bundle config --global frozen 1 && \
    apk upgrade --available && sync

COPY . .

RUN bundle install

USER 1001

CMD ["ruby", "analyzer.rb"]