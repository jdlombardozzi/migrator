# frozen_string_literal: true

namespace :export do
  # @example bundle exec rake export:properties
  desc 'List properties'
  task :list_properties do
    puts ::Migrator::App["legacy.rom"].relations[:properties].map { |p| "#{p[:property_name]} - #{p[:property_uuid]}" }
  end
end
