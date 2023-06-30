module Migrator
  module Target
    module Relations
      class OtaTokens < ROM::Relation[:sql]
        schema(:ota_tokens, infer: true)
      end
    end
  end
end