module Migrator
  module Target
    module Relations
      class MigratorLinks < ROM::Relation[:sql]
        schema(:migrator_links, infer: true)
      end
    end
  end
end