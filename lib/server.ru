require "bundler/setup"
require "rack"
require_relative "../lib/utils"

PATH_INFO   = "PATH_INFO"
SERVER_PORT = "SERVER_PORT"
EXPIRATION  = { "Cache-Control" => "public, max-age=31536000" }
NOT_FOUND   = [404, {}, ["Not Found"]]

EXPERIMENT_NAME = "name"

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
  end

  def call(env)
    path = env[PATH_INFO]
    port = env[SERVER_PORT]
    index = port.to_i - BASE_PORT
    experiment = experiments[index][EXPERIMENT_NAME]
    env[PATH_INFO] = "app-#{experiment}#{path}"
    @app.call(env)
  end
end

use FarFutureExpire
use InternalRedirect
use Rack::Static, urls: [""], root: "dist", index: "index.html"

run ->(env) { NOT_FOUND }
