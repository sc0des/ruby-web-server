#!/usr/bin/env ruby
# frozen_string_literal: true

# This is a basic web application in Ruby. Please read "Ruby in Twenty Minutes"
# guide first: https://www.ruby-lang.org/en/documentation/quickstart/

# The app uses Sinatra framework, start with http://sinatrarb.com/intro.html

# To check syntax of your application before running please run:
# rubocop webapp.rb

# libraries
require 'json'
require 'neatjson'
require 'sinatra'
require "sinatra/cookies"
require 'digest/sha1'
require 'geocoder'

# Sinatra configuration: listen on a dedicated port of localhost. The port is selected
# automatically based on your numeric user ID, starting from 8080.
set :port, (7080 + Process.euid)

# Sinatra configuration: static files (images, JavaScript code, etc) can be placed here
set :public_folder, 'public'

# Sinatra configuration: a folder for ERB templates
set :views, 'templates'

# Respond to a basic HTTP request (GET /)
get '/' do
  # Set a HTML Content-Type header to "Text" and Cookie
  content_type :text
  "value: #{cookies[:something]}"
  # Return headers and environment values from the "request" object, processed as a JSON
  return JSON.pretty_generate(request.env)
end

# Request Header
get "/show-fingerprint" do
  FingerprintCollection = {
    "REQUEST_METHOD" => request.env["REQUEST_METHOD"],
    "HTTP_VERSION" => request.env["HTTP_VERSION"],
    "HTTP_ACCEPT" => request.env["HTTP_ACCEPT"],
    "HTTP_CONNECTION" => request.env["HTTP_CONNECTION"],
    "HTTP_USER_AGENT" => request.env["HTTP_USER_AGENT"],
    "HTTP_ACCEPT_LANGUAGE" => request.env["HTTP_ACCEPT_LANGUAGE"],
    "HTTP_ACCEPT_ENCODING" => request.env["HTTP_ACCEPT_ENCODING"],
    "HTTP_COOKIE" => request.env["HTTP_COOKIE"],
    "HTTP_X_REAL_IP" => request.env["HTTP_X_REAL_IP"],
    "HTTP_HOST" => request.env["HTTP_HOST"],
    "REQUEST_PATH" => request.env["REQUEST_PATH"],
    "HTTP_SEC_CH_UA" => request.env["HTTP_SEC_CH_UA"],
    "HTTP_SEC_CH_UA_PLATFORM" => request.env["HTTP_SEC_CH_UA_PLATFORM"]
  }
  
  # Request Location 
  city = JSON.neat_generate(request.location.city)
  country =JSON.neat_generate(request.location.country_code)
  location = JSON.neat_generate(request.location.inspect)
  
  # Save into JSON file
  File.open("public/fingerprint.json","w") do |f|
    f.write(FingerprintCollection.to_json)
    f.write(city)
    f.write(country)
    f.write(location)
 end
  return "Saved fingerprints as JSON file"
end

# Response Header
get "/show-json" do
 content_type :json 
 File.read("public/fingerprint.json")
end

# Fingerprint Hash
get "/show-hash" do

  HashValue= Digest::SHA256.hexdigest(request.env["REQUEST_METHOD"]) + Digest::SHA256.hexdigest(request.env["HTTP_VERSION"]) + 
  Digest::SHA256.hexdigest(request.env["HTTP_ACCEPT"]) + Digest::SHA256.hexdigest(request.env["HTTP_CONNECTION"]) + 
  Digest::SHA256.hexdigest(request.env["HTTP_USER_AGENT"]) + Digest::SHA256.hexdigest(request.env["HTTP_ACCEPT_LANGUAGE"]) + 
  Digest::SHA256.hexdigest(request.env["HTTP_ACCEPT_ENCODING"]) + Digest::SHA256.hexdigest(request.env["HTTP_COOKIE"]) + 
  Digest::SHA256.hexdigest(request.env["HTTP_X_REAL_IP"]) + Digest::SHA256.hexdigest(request.env["HTTP_HOST"]) + 
  Digest::SHA256.hexdigest(request.env["REQUEST_PATH"]) + Digest::SHA256.hexdigest(request.env["HTTP_SEC_CH_UA"]) + 
  Digest::SHA256.hexdigest(request.env["HTTP_SEC_CH_UA_PLATFORM"]) + Digest::SHA256.hexdigest(request.location.city) + 
  Digest::SHA256.hexdigest(request.location.country_code) + Digest::SHA256.hexdigest(request.location.inspect)
 return HashValue 
end

# Respond to a basic HTTP request with template rendering (GET /render)
get '/render' do
  # Render a page from "templates/status.erb" file with some local variables set
  erb :status, locals: { 'info_header' => 'Hello?', 'info_message' => 'Bye!' }
end

# Cookie Set
get '/set' do
  cookies[:something] = 'foobar'
  redirect to('/')
end

# Counter 
get '/set' do
  cookies[:something] ||=0
  cookies[:something] = cookies[:something].to_i + 1
  "something #{cookies[:something]}"
end

get '/demo' do
  cookies.merge! 'foo' => 'bar', 'bar' => 'baz'
  cookies.keep_if { |key, value| key.start_with? 'b' }
  foo, bar = cookies.values_at 'foo', 'bar'
  "size: #{cookies.length}"
end

post '/' do
  response.set_cookie("my_cookie", :value => "foobar",:path => '/',:expires => Date.new(2022,6,6))
end

get '/' do
  cookie = request.cookies["my_cookie"]
end

# EOF
