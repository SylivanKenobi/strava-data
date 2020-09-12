FROM ruby:2.7-alpine

COPY analyzer.rb .
COPY Gemfile .
COPY strava/activities.csv .

RUN bundle install

CMD ["ruby", "analyzer.rb"]