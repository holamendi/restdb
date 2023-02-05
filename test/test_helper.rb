ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"
require "json"
require "app"

App::DB.create_table :users do
  primary_key :id
  column :name, :text
  column :email, :text
end

App::DB[:users].insert(name: "Tom Olson", email: "tom@example.com")
App::DB[:users].insert(name: "Jane Doe", email: "jane@exmaple.com")
