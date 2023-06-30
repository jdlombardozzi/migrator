module Migrator
  module Target
    module Relations
      class IframeTxnLogs < ROM::Relation[:sql]
        schema(:iframe_txn_logs, infer: true)
      end
    end
  end
end