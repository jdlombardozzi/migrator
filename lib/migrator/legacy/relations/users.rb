module Migrator
  module Legacy
    module Relations
      class Users < ROM::Relation[:sql]
        schema(:users, infer: true) do
          attribute :user_uuid, Types::String.meta(primary_key: true)

          associations do
            has_many :iframe_txn_logs, foreign_key: :user_uuid, primary_key: :user_uuid
            has_many :ota_tokens, foreign_key: :user_uuid, primary_key: :user_uuid
            has_many :properties, as: :chain_holder_properties, foreign_key: :chain_holder_uuid, primary_key: :user_uuid
            has_many :system_logs, foreign_key: :user_uuid, primary_key: :user_uuid
            has_many :webhook_transaction_logs, foreign_key: :user_uuid, primary_key: :user_uuid
          end
        end
      end
    end
  end
end