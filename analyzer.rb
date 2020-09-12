require "influxdb"
require 'json'

username = 'test'
password = 'test'
database = 'test'
host = 'localhost'

$influxdb = InfluxDB::Client.new host: host, database: database, username: username, password: password

$influxdb.delete_database('test')
$influxdb.create_database('test')

# Get Token
# curl -X POST https://www.strava.com/api/v3/oauth/token \    
#   -d client_id= \
#   -d client_secret= \
#   -d code= \
#   -d grant_type=authorization_code

# Get Activities
# curl -G https://www.strava.com/api/v3/athlete/activities -H "Authorization: Bearer "

$influxdb.write_point('activities', data)

