module Migrator
  module Target
    module Relations
      class MerchantGateways < ROM::Relation[:sql]
        schema(:merchant_gateways, infer: true)
      end
    end
  end
end