Hanami.app.register_provider :legacy, namespace: true do
  prepare do
    require "rom"

    config = ROM::Configuration.new(:sql, target["settings"].legacy_database_url)

    register "config", config
    register "db", config.gateways[:default].connection
  end

  start do
    config = target["legacy.config"]

    config.auto_registration(
      target.root.join("lib/migrator/legacy"),
      namespace: "Migrator::Legacy"
    )

    register "rom", ROM.container(config)
  end
end
