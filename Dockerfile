FROM ruby:2.7

COPY . .
RUN bundle install

CMD ["ruby", "analyzer.rb"]