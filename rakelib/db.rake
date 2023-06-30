namespace :db do
  task setup: :environment do
    Hanami.app.prepare(:persistence)
    ROM::SQL::RakeSupport.env = Hanami.app["persistence.config"]
  end
end