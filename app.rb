require "roda"
require "sequel"

DB = Sequel.connect(ENV.fetch("DATABASE_URL", "sqlite://examples/db.sqlite3"))

class App < Roda
  plugin :json

  route do |r|
    r.on("api") do
      DB.tables.each do |table|
        r.on(table) do
          r.get do
            params = r.params.transform_keys(&:to_sym)
            invalid_params = params.keys - DB[table].columns

            if invalid_params.any?
              response.status = 400
              return {error: "invalid parameters: #{invalid_params.join(", ")}"}
            end

            {table => DB[table].where(params).all}
          end
        end
      end
    end

    r.get("health") { "OK" }
  end
end
