require "anyway_config"

class DbRestApiConfig < Anyway::Config
  attr_config :database_url,
    :included_tables

  coerce_types included_tables: {type: :string, array: true}
end
