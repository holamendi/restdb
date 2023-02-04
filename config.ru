require "roda"
require_relative "sqlite_rest_api"

run SqliteRestApi.freeze.app
