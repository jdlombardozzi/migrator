module Migrator
  module Target
    module Relations
      class StandaloneRefundLogs < ROM::Relation[:sql]
        schema(:standalone_refund_logs, infer: true)
      end
    end
  end
end