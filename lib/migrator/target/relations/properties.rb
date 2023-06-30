module Migrator
  module Target
    module Relations
      class Properties < ROM::Relation[:sql]
        schema(:properties, infer: true)
      end
    end
  end
end