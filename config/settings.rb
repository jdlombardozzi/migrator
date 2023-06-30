# frozen_string_literal: true

module Migrator
  class Settings < Hanami::Settings
    # Define your app settings here, for example:
    #
    # setting :my_flag, default: false, constructor: Types::Params::Bool
    setting :legacy_database_url, constructor: Types::String
    setting :target_database_url, constructor: Types::String
  end
end
