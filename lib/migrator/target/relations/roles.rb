module Migrator
  module Target
    module Relations
      class Roles < ROM::Relation[:sql]
        schema(:roles, infer: true) do
          associations do
            belongs_to :users, foreign_key: :created_by
          end
        end
      end
    end
  end
end