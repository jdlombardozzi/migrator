module Migrator
  module Legacy
    module Relations
      class AuthorizationAdjustmentLogs < ROM::Relation[:sql]
        schema(:authorization_adjustment_logs, infer: true) do
          associations do
            belongs_to :gateway_reference_numbers, foreign_key: :reference_number, primary_key: :reference_number
          end
        end
      end
    end
  end
end