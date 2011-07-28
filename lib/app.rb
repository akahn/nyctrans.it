require 'haml'
require 'sinatra/base'
require_relative './route'

class App < Sinatra::Base
  set :views, File.dirname(__FILE__) + "/views"
  set :haml, :format => :html5
  enable :inline_templates

  get "/:route" do
    @route = Route.new(params[:route])
    haml :route
  end
end

__END__

@@ layout
!!!
%head
  %title== nyctrans.it - #{@route.to_s}
  :css
    body {
      font-family: Helvetica, sans-serif;
    }
%body
  = yield
