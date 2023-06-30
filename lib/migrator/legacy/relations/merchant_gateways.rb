module Migrator
  module Legacy
    module Relations
      class MerchantGateways < ROM::Relation[:sql]
        schema(:merchant_gateways, infer: true) do
          attribute :gateway_uuid, Types::String.meta(primary_key: true)

          # For some reason terminal uses the id as the FK, but others use gateway_uuid

          associations do
            has_many :gateway_reference_numbers, foreign_key: :gateway_uuid
            has_many :terminals, foreign_key: :gateway_id
          end
        end
      end
    end
  end
end