module Migrator
  module Target
    module Relations
      class Users < ROM::Relation[:sql]
        schema(:user, infer: true)
      end
    end
  end
end