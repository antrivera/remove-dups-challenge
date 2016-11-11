require 'sinatra'
require 'json'
require './lib/app_helper.rb'

before %r{/(.+)} do
  content_type :json
end

get '/' do
  erb :index
end

get '/emails' do
  num_unique = params["unique"].to_i
  emails = create_email_list(num_unique).to_json
end

post '/unique_emails' do
  json = JSON.parse(request.body.read, symbolize_names: true)
  remove_duplicates(json[:emails]).to_json
end
