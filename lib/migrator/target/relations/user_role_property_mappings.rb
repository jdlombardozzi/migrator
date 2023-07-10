module Migrator
  module Target
    module Relations
      class UserRolePropertyMappings < ROM::Relation[:sql]
        schema(:user_role_property_mappings, infer: true) do
          associations do
            belongs_to :user
            belongs_to :role
            belongs_to :property
          end
        end
      end
    end
  end
end