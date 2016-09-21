require "bundler/setup"
require "rack"
require "set"
require_relative "../lib/utils"

PATH_INFO   = "PATH_INFO"
SERVER_PORT = "SERVER_PORT"
EXPIRATION  = { "Cache-Control" => "public, max-age=31536000" }
PRELOAD     = [200, { "Content-Type" => "text/html" }, [read_file("config/preload.html")]]

PRELOAD_HTML = "/preload.html"

class FarFutureExpire
  def initialize(app, *)
    @app = app
  end

  def call(env)
    puts env[PATH_INFO]
    result = @app.call(env)
    result[1].merge!(EXPIRATION)
    result
  end
end

class InternalRedirect
  def initialize(app, *)
    @app = app
    @base_paths = {}
    @index = {}
    @non_asset_paths = Set.new ["", "/"]

    experiments.each_with_index do |experiment, i|
      app_port = (BASE_PORT + i).to_s
      base_path = "app-#{experiment['name']}"

      @base_paths[app_port] = base_path
      @index[app_port] = [200, { "Content-Type" => "text/html" }, [read_file("dist/#{base_path}/index.html")]]
    end
  end

  def call(env)
    real_path = env[PATH_INFO]
    port = env[SERVER_PORT]

    if real_path == PRELOAD_HTML
      PRELOAD
    elsif @non_asset_paths.include?(real_path)
      # route all non-asset paths to the Ember app
      @index[port]
    else
      env[PATH_INFO] = @base_paths[port] + real_path
      res = @app.call(env)

      if res[0] == 404
        @non_asset_paths << real_path
        @index[port]
      else
        res
      end
    end
  end
end

use FarFutureExpire
use InternalRedirect

run Rack::File.new(full_path("dist"))
