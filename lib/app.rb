require 'haml'
require 'sinatra/base'
require_relative './route'

class App < Sinatra::Base
  set :views, File.dirname(__FILE__) + "/views"

  get "/:route" do
    @route = Route.new(params[:route])
    haml :route
  end
end
