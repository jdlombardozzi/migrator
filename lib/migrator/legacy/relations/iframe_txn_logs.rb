module Migrator
  module Legacy
    module Relations
      class IframeTxnLogs < ROM::Relation[:sql]
        schema(:iframe_txn_logs, infer: true) do
          associations do
            belongs_to :gateway_reference_numbers, foreign_key: :reference_number
            belongs_to :properties, foreign_key: :property_uuid
            belongs_to :users, foreign_key: :user_uuid
          end
        end
      end
    end
  end
end