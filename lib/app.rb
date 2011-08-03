require 'haml'
require 'sinatra/base'
require_relative './route'

class App < Sinatra::Base
  set :views, File.dirname(__FILE__) + "/views"
  set :haml, :format => :html5
  enable :inline_templates

  get "/" do
    if params[:route]
      redirect "/#{params[:route]}"
    else
      haml :home
    end
  end

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
    body, input {
      font-family: Helvetica, sans-serif;
    }

    .train {
      border-radius: 50px;
      width: 100px;
      height: 100px;
      display: inline-block;
      text-align: center;
      text-decoration: none;
      color: white;
      font-size: 80px;
      font-weight: bold;
      margin-right: 5px;
    }

    .row { margin-bottom: 10px }

    .green { background-color: #66FF00; }
    .forest { background-color: #228B22; }
    .purple { background-color: purple; }
    .red { background-color: red; }
    .blue { background-color: blue; }
    .yellow { background-color: yellow; }
    .orange { background-color: orange; }
    .marigold { background-color: gold; }
    .gray { background-color: gray; }

    #bus-route {
      border-radius: 10px;
      width: 200px;
      color: white;
      background-color: DarkBlue;
      font-size: 80px;
      font-weight: bold;
      text-align: center;
      outline: none;
      border: none;
      padding: 4px;
    }

    ::-webkit-input-placeholder,
    ::-moz-placeholder {
      color: white;
      text-indent: 20px;
    }

%body
  = yield

  :javascript
    var input = document.getElementById('bus-route');
    if (input) {
      input.onkeyup = function(e) {
        this.value = this.value.toUpperCase();
      };
    }
