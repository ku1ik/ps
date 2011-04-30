require 'bundler'
Bundler.setup

require File.join(File.dirname(__FILE__), 'app.rb')

run Sinatra::Application
