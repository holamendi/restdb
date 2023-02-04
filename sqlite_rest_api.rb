require "sequel"
require "debug"

DB = Sequel.connect("sqlite://examples/db.sqlite3")

class SqliteRestApi < Roda
  plugin :json

  route do |r|
    r.on("api") do
      DB.tables.each do |table|
        r.on(table) do
          r.get do
            params = r.params.transform_keys(&:to_sym)

            params.keys.each do |key|
              unless DB[table].columns.include?(key.to_sym)
                response.status = 400
                return {error: "invalid parameters"}
              end
            end

            {table => DB[table].where(params).all}
          end
        end
      end
    end
  end
end
