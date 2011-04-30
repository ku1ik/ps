require 'sinatra'
require 'json'

require File.join(File.dirname(__FILE__), 'ps.rb')

get '/' do
  list = Ps.all(:filter => params[:filter], :order => params[:order])

  content_type :json
  list.to_json
end

get %r(/(\d+)) do
  pid = params[:captures][0].to_i
  details = Ps.details(pid) or raise Sinatra::NotFound

  content_type :json
  details.to_json
end
