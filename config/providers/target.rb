Hanami.app.register_provider :target, namespace: true do
  prepare do
    require "rom"

    config = ROM::Configuration.new(:sql, target["settings"].target_database_url)

    register "config", config
    register "db", config.gateways[:default].connection
  end

  start do
    config = target["target.config"]

    config.auto_registration(
      target.root.join("lib/migrator/target"),
      namespace: "Migrator::Target"
    )

    register "rom", ROM.container(config)
  end
end
