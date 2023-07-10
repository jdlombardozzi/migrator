module Migrator
  module Target
    module Relations
      class AclModules < ROM::Relation[:sql]
        schema(:acl_modules, infer: true)
      end
    end
  end
end