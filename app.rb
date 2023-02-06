require "roda"
require "sequel"
require_relative "helpers/pagination_helper"

class App < Roda
  include PaginationHelper

  plugin :environments
  plugin :halt
  plugin :json
  plugin :render
  plugin :symbolized_params

  configure :development, :production do
    plugin :enhanced_logger
  end

  DB = if test?
    Sequel.sqlite
  else
    Sequel.connect(ENV["DATABASE_URL"], readonly: true)
  end

  DB.extension(:pagination)

  route do |r|
    r.root { "Look behind you, a three headed monkey!" }

    r.on :api do
      r.on String do |resource|
        table = resource.to_sym
        r.halt(404, {error: "resource '#{resource}' not found"}) unless DB.tables.include?(table)

        # GET /api/:resource
        r.is do
          invalid_filters = params.except(:page, :page_size).keys - DB[table].columns
          r.halt(400, {error: "invalid filters: #{invalid_filters.join(", ")}"}) if invalid_filters.any?

          DB[table].where(params).paginate(*pagination_params(params)).all
        end

        # GET /api/:resource/:id
        r.is String do |id|
          row = DB[table].where(id: id).first
          r.halt(404, {error: "resource '#{resource} with id '#{id}' not found"}) if row.nil?

          row
        end
      end
    end

    r.get("health") { "OK" }
  end
end
