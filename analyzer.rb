require "influxdb"
require 'json'
require 'rest-client'
require 'rufus-scheduler'
require 'net/http'
require 'uri'
require_relative 'lib/secrets'

scheduler = Rufus::Scheduler.new

$influxdb = InfluxDB::Client.new host: Secrets.get('DB_HOST'), database: Secrets.get('DB_DATABASE'), username: Secrets.get('DB_USERNAME'), password: Secrets.get('DB_PW')
$influxdb.create_database('test')

def send_data(data)
  data.each do |d|
    value = {
      values: { distance: d['distance'], duration: d['moving_time'], avg_speed: d['average_speed'].to_i * 3.6, max_speed: d['max_speed'].to_i * 3.6, elevation: d['total_elevation_gain']},
      timestamp: DateTime.iso8601(d['start_date_local']).to_time.to_i
    }
    $influxdb.write_point('activities', value)
  end
end

def get_data(token)
  url = 'https://www.strava.com/api/v3/athlete/activities'
  response = RestClient::Request.execute(
      method: :get, url: url, headers: { Authorization: "Bearer #{token}" }
    )
  json = JSON.parse(response.body)
  json
end


def get_token
  if token_expired?
    uri = URI.parse("https://www.strava.com/api/v3/oauth/token")
    request = Net::HTTP::Post.new(uri)
    request.set_form_data(
      "client_id" => Secrets.get('CLIENT_ID'),
      "client_secret" => Secrets.get('CLIENT_SECRET'),
      "grant_type" => "refresh_token",
      "refresh_token" => Secrets.get('REFRESH_TOKEN')
    )
    
    req_options = { use_ssl: uri.scheme == "https" }
    
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    @token_response = JSON.parse(response.body)
    @bearer_token = @token_response['access_token']
    @bearer_token
  else
    @bearer_token
  end
end

def token_expired?
  @bearer_token.nil? || Time.at(@token_response['expires_at'].to_i) < Time.now
end


scheduler.cron '0 */1 * * *', :first_in => 0 do
  pp 'fetching new token'
  token = get_token
  pp 'fetching new data'
  data = get_data(token)
  pp 'sending data to influx'
  send_data(data)
  pp 'sent'
  pp 'see ya in an hour'
end

scheduler.join
