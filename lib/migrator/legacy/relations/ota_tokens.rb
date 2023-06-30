module Migrator
  module Legacy
    module Relations
      class OtaTokens < ROM::Relation[:sql]
        schema(:ota_tokens, infer: true) do
          associations do
            belongs_to :users, foreign_key: :user_uuid
            belongs_to :properties, foreign_key: :property_uuid
          end
        end
      end
    end
  end
end