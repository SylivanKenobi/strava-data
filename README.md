Datascraper and Visualizer for Strava with Ruby, Grafana and Influx.

### Prerequisites:

* docker
* docker-compose
* ruby 2.7
* bundler

### Start app:

* create file `assets/secrets.yml` with the needed secrets
* `$ bundle install`
* `$ docker-compose up -d`
* `$ ruby analyzer.rb`

Visit Grafana on http://localhost:3000.