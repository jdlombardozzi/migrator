module Migrator
  module Target
    module Relations
      class GatewayReferenceNumbers < ROM::Relation[:sql]
        schema(:gateway_reference_numbers, infer: true)
      end
    end
  end
end