module Migrator
  module Target
    module Relations
      class Terminals < ROM::Relation[:sql]
        schema(:terminals, infer: true)
      end
    end
  end
end