Datascraper and Visualizer for Strava with Ruby, Grafana and Influx.

### Prerequisites:

* docker
* docker-compose
* ruby 2.7
* bundler

### Start app:

* Register your app on strava. How to's:
    * https://developers.strava.com/docs/authentication/
    * https://www.youtube.com/watch?v=sgscChKfGyg
* create file `assets/secrets.yml` with the needed secrets
    * CLIENT_ID:
    * CLIENT_SECRET:
    * REFRESH_TOKEN:
    * DB_HOST:
    * DB_DATABASE:
    * DB_PW:
    * DB_USERNAME:
* `$ bundle install`
* `$ docker-compose up -d`
* `$ ruby analyzer.rb`
* Visit Grafana on http://localhost:3000
* Login user: admin, pw: password