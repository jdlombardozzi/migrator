module Migrator
  module Target
    module Relations
      class WebhookTransactionLogs < ROM::Relation[:sql]
        schema(:webhook_transaction_logs, infer: true)
      end
    end
  end
end