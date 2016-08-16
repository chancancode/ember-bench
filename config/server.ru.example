require "bundler/setup"
require "rack"

APP_PREFIX = "/app"
COOKIE     = "HTTP_COOKIE"
PATH_INFO  = "PATH_INFO"
EXPIRATION = { "Cache-Control" => "public, max-age=31536000" }
NOT_FOUND  = [404, {}, ["Not Found"]]

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
    if env[PATH_INFO].start_with?(APP_PREFIX) && env.key?(COOKIE)
      env[PATH_INFO] = env[COOKIE]
    end

    @app.call(env)
  end
end

use FarFutureExpire
use InternalRedirect
use Rack::Static, urls: [""], root: "dist/merged"

run ->(env) { NOT_FOUND }
