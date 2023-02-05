require "roda"
require "sequel"
require "debug"

DB = Sequel.connect(ENV.fetch("DATABASE_URL"), readonly: true)
DB.extension(:pagination)

class App < Roda
  plugin :environments
  plugin :json
  plugin :render

  configure :development, :production do
    plugin :enhanced_logger
  end

  route do |r|
    r.root { view :index }

    r.on :api do
      r.on String do |resource|
        table = resource.to_sym

        unless DB.tables.include?(table)
          response.status = 404
          return {error: "resource '#{resource}' not found"}
        end

        # GET /api/:resource
        r.is do
          params = r.params.transform_keys(&:to_sym)

          page = params.delete(:page) || 1

          if page.to_i <= 0
            response.status = 400
            return {error: "the 'page' parameter must be greater than 0"}
          end

          page_size = params.delete(:page_size) || 200

          if !page_size.to_i.between?(10, 200)
            response.status = 400
            return {error: "the 'page_size' parameter must be between 10 and 200"}
          end

          invalid_filters = params.keys - DB[table].columns

          if invalid_filters.any?
            response.status = 400
            return {error: "invalid parameters: #{invalid_filters.join(", ")}"}
          end

          DB[table].where(params).paginate(page.to_i, page_size.to_i).all
        end

        # GET /api/:resource/:id
        r.is String do |id|
          row = DB[table].where(id: id).first

          if row.nil?
            response.status = 404
            return {error: "resource '#{resource} with id '#{id}' not found"}
          end

          row
        end
      end
    end

    r.get("health") { "OK" }
  end
end
