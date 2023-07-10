module Migrator
  module Legacy
    module Relations
      class Properties < ROM::Relation[:sql]
        schema(:properties, infer: true) do
          attribute :property_uuid, Types::String.meta(primary_key: true)

          associations do
            belongs_to :chain_holders, relation: :users, foreign_key: :chain_holder_id
            belongs_to :merchant_gateway, relation: :merchant_gateways, foreign_key: :payment_gateway_id
            belongs_to :users, as: :created_by, foreign_key: :created_by
            has_many :webhook_transaction_logs, foreign_key: :property_uuid, primary_key: :property_uuid
          end
        end
      end
    end
  end
end