# frozen_string_literal: true

namespace :migrator do
  # @example bundle exec rake migrator:copy_property\[456a991c-9d9f-11ed-8777-7f4c21336ead\]
  desc 'Migrate property by uuid'
  task :copy_property, [:uuid] => [:environment] do |t, args|
    ::Migrator::Migrate::CopyProperty.call(args[:uuid])
  end

  # @example bundle exec rake migrator:truncate_property\[456a991c-9d9f-11ed-8777-7f4c21336ead\]
  desc 'Truncate property by uuid'
  task :truncate_property, [:uuid] => [:environment] do |t, args|
    ::Migrator::Migrate::TruncateProperty.call(args[:uuid])
  end
end
