module Migrator
  module Legacy
    module Relations
      class Terminals < ROM::Relation[:sql]
        schema(:terminals, infer: true) do
          associations do
            belongs_to :merchant_gateway, foreign_key: :gateway_id
          end
        end
      end
    end
  end
end