module Migrator
  module Legacy
    module Relations
      class GatewayReferenceNumbers < ROM::Relation[:sql]
        schema(:gateway_reference_numbers, infer: true) do
          attribute :reference_number, Types::String.meta(primary_key: true)

          associations do
            belongs_to :merchant_gateways, foreign_key: :reference_number
            has_many :authorization_adjustment_logs, foreign_key: :reference_number
            has_many :iframe_txn_logs, foreign_key: :reference_number
            has_many :webhook_transaction_logs, foreign_key: :reference_number, primary_key: :reference_number
          end
        end
      end
    end
  end
end