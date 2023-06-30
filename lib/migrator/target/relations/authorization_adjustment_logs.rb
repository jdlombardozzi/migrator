module Migrator
  module Target
    module Relations
      class AuthorizationAdjustmentLogs < ROM::Relation[:sql]
        schema(:authorization_adjustment_logs, infer: true)
      end
    end
  end
end