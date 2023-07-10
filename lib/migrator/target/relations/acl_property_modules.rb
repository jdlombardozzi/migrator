module Migrator
  module Target
    module Relations
      class AclPropertyModules < ROM::Relation[:sql]
        schema(:acl_property_modules, infer: true) do
          associations do
            belongs_to :property
            belongs_to :acl_module
          end
        end
      end
    end
  end
end