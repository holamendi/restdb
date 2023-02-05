ENV["RACK_ENV"] = "test"
ENV["DATABASE_URL"] = "sqlite://test/db/db.sqlite3"

require "minitest/autorun"
require "rack/test"
require "json"
require "app"
