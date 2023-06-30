module Migrator
  module Legacy
    module Relations
      class WebhookTransactionLogs < ROM::Relation[:sql]
        schema(:webhook_transaction_logs, infer: true) do
          associations do
            belongs_to :gateway_reference_numbers, foreign_key: :reference_number, primary_key: :reference_number
            belongs_to :properties, foreign_key: :property_uuid, primary_key: :property_uuid
            belongs_to :user, foreign_key: :user_uuid, primary_key: :user_uuid
          end
        end
      end
    end
  end
end