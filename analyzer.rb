require "influxdb"
require 'json'
require 'rest-client'
require 'rufus-scheduler'
require 'net/http'
require 'uri'
require_relative 'lib/secrets'
require 'logger'
# require 'pry'

log_path = ENV['LOG_PATH'] || "/dev/stdout"
logger = Logger.new(log_path)
scheduler = Rufus::Scheduler.new

$influxdb = InfluxDB::Client.new host: Secrets.get('DB_HOST'), database: Secrets.get('DB_DATABASE'), username: Secrets.get('DB_USERNAME'), password: Secrets.get('DB_PW')
$influxdb.delete_database('test')
$influxdb.create_database('test')

def send_activities(activities)
  activities.each do |d|
    value = {
      values: { 
        id: d['id'],
        type: d['type'],
        distance: d['distance'].to_f,
        duration: d['moving_time'].to_f,
        avg_speed: d['average_speed'].to_i * 3.6,
        max_speed: d['max_speed'].to_i * 3.6,
        elevation: d['total_elevation_gain'].to_f,
        max_watts: d['max_watts'].to_f,
        average_watts: d['average_watts'].to_f,
        weighted_average_watts: d['weighted_average_watts'].to_f
      },
      tags: {
        year: DateTime.iso8601(d['start_date_local']).year,
        type: d['type']
      },
      timestamp: DateTime.iso8601(d['start_date_local']).to_time.to_i
    }
    $influxdb.write_point('activities', value)
  rescue => e
    logger.info("#{e.message} #{value}")
  end
end

def send_segments(segments)
  segments.each_with_index do |d,i|
    pr_time = d['pr_time'] || 0
    value = {
      values: { prtime: pr_time},
      tags: {
        name: d['name']
      },
      timestamp: Time.now.to_i + i
    }
    $influxdb.write_point('segments', value)
  rescue => e
    logger.info("#{e.message} #{value}")
  end
end

def get_data(path, token)
  data = []
  i = 0
  loop do
    i += 1
    url = "https://www.strava.com/api/v3/#{path}?page=#{i}&per_page=200"
    response = RestClient::Request.execute(
        method: :get, url: url, headers: { Authorization: "Bearer #{token}" }
    )
    break if JSON.parse(response.body).nil? || JSON.parse(response.body).empty?
    data = data + JSON.parse(response.body)
  end
  data
end

def uptodate(token)
  url = "https://www.strava.com/api/v3/athlete/activities"
  response = RestClient::Request.execute(
      method: :get, url: url, headers: { Authorization: "Bearer #{token}" }
  )
  json = JSON.parse(response.body)
  !$influxdb.query('select * from activities where id =' + json[0]['id'].to_s).empty?
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

def write_to_file(data)
  File.open("assets/data.json", "w") { |f| f.write data.to_json }
end

def get_data_from_file
  data = File.read("assets/data.json")
  JSON.parse(data)
end


scheduler.every '30m', :first_in => 0 do
  logger.info('fetching new token')
  token = get_token
  logger.info('check if data is up to date')
  unless uptodate(token)
    logger.info('fetching new data')
    activities = get_data('athlete/activities',token)
    
    segments = get_data('segments/starred',token)
    # segments = get_data_from_file
    logger.info('sending data to influx')
    send_activities(activities)
    send_segments(segments)
    # write_to_file(segments)
    logger.info('sent')
  else
    logger.info('data is up to date')
  end
  logger.info('see ya in 30 min')
end

scheduler.join
