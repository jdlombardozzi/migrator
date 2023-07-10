# frozen_string_literal: true

# require "hanami/rake_tasks"
require "rom/sql/rake_task"
require "hanami/prepare"

Rake.add_rakelib "lib/tasks"

task :environment do
  require_relative "config/app"
  require "hanami/prepare"
end

namespace :db do
  task setup: :environment do
    Hanami.app.prepare(:target)
    ROM::SQL::RakeSupport.env = Hanami.app["target.rom"]
  end
end

Hanami.prepare