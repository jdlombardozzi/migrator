module Migrator
  module Migrate
    class CopyProperty
      attr_reader :legacy_property, :target_property

      class << self
        # @param [String] uuid The uuid of the property to migrate
        def call(uuid)
          new(uuid).call
        end
      end

      # @param [String] uuid The uuid of the property to migrate
      def initialize(uuid)
        @legacy_property = ::Migrator::App["legacy.rom"].relations[:properties].where(property_uuid: uuid).one
      end

      def call
        migrate_merchant_gateway
        migrate_property
        migrate_property_user
        migrate_gateway_reference_numbers
        migrate_terminals
        migrate_iframe_txn_logs
        migrate_ota_tokens
        migrate_system_logs
        migrate_webhook_transaction_logs
      end

      private

      def legacy_merchant_gateway
        return if legacy_property[:payment_gateway_id].nil?

        @legacy_merchant_gateway ||= ::Migrator::App["legacy.rom"].relations[:merchant_gateways].where(id: legacy_property[:payment_gateway_id]).one
      end

      def migrate_gateway_reference_numbers
        # Migrate gateway_reference_number
        ::Migrator::App["legacy.rom"].relations[:gateway_reference_numbers].where(gateway_uuid: legacy_merchant_gateway[:gateway_uuid]).each do |legacy_gateway_reference_number|
          legacy_gateway_reference_number_id = legacy_gateway_reference_number.delete(:id)
          legacy_gateway_reference_number[:gateway_id] = target_merchant_gateway[:id]
          target_gateway_reference_number = ::Migrator::App["target.rom"].relations[:gateway_reference_numbers].changeset(:create, legacy_gateway_reference_number).commit
          ::Migrator::App["target.rom"].relations[:migrator_links].changeset(:create, session: legacy_property[:property_uuid], target_id: target_gateway_reference_number[:id], legacy_id: legacy_gateway_reference_number_id, type: 'gateway_reference_number').commit

          # Migrate authorization_adjustment_logs (depends on gateway_reference_number)
          ::Migrator::App["legacy.rom"].relations[:authorization_adjustment_logs].where(reference_number: legacy_gateway_reference_number[:reference_number]).each do |legacy_authorization_adjustment_log|
            legacy_authorization_adjustment_log_id = legacy_authorization_adjustment_log.delete(:id)
            target_authorization_adjustment_log = ::Migrator::App["target.rom"].relations[:authorization_adjustment_logs].changeset(:create, legacy_authorization_adjustment_log).commit
            ::Migrator::App["target.rom"].relations[:migrator_links].changeset(:create, session: legacy_property[:property_uuid],  target_id: target_authorization_adjustment_log[:id], legacy_id: legacy_authorization_adjustment_log_id, type: 'authorization_adjustment_log').commit
          end

          # Migrate standalone_refund_logs (depends on reference)
          ::Migrator::App["legacy.rom"].relations[:standalone_refund_logs].where(reference_number: legacy_gateway_reference_number[:reference_number]).each do |legacy_standalone_refund_log|
            legacy_standalone_refund_log_id = legacy_standalone_refund_log.delete(:id)
            target_standalone_refund_log = ::Migrator::App["target.rom"].relations[:standalone_refund_logs].changeset(:create, legacy_standalone_refund_log).commit
            ::Migrator::App["target.rom"].relations[:migrator_links].changeset(:create, session: legacy_property[:property_uuid],  target_id: target_standalone_refund_log[:id], legacy_id: legacy_standalone_refund_log_id, type: 'standalone_refund_log').commit
          end
        end
      end

      # Migrate iframe_txn_logs (depends on reference, user, property)
      def migrate_iframe_txn_logs
        ::Migrator::App["legacy.rom"].relations[:iframe_txn_logs].where(property_uuid: target_property[:property_uuid]).each do |legacy_iframe_txn_log|
          legacy_iframe_txn_log_id = legacy_iframe_txn_log.delete(:id)
          target_iframe_txn_log = ::Migrator::App["target.rom"].relations[:iframe_txn_logs].changeset(:create, legacy_iframe_txn_log).commit
          ::Migrator::App["target.rom"].relations[:migrator_links].changeset(:create, session: legacy_property[:property_uuid], target_id: target_iframe_txn_log[:id], legacy_id: legacy_iframe_txn_log_id, type: 'iframe_txn_log').commit
        end
      end

      def migrate_merchant_gateway
        return if legacy_merchant_gateway.nil?

        # Migrate the chain holder
        legacy_chain_holder = ::Migrator::App["legacy.rom"].relations[:users].where(id: legacy_merchant_gateway[:created_by]).one

        raise 'Discrepancy between chain holder of property and gateway creator' unless legacy_chain_holder[:user_uuid] == legacy_property[:chain_holder_id]

        # Create the chain holder user in target repo
        legacy_user_id = legacy_chain_holder.delete(:id)
        @target_chain_holder = ::Migrator::App["target.rom"].relations[:users].changeset(:create, legacy_chain_holder).commit

        # Create a link for the user
        ::Migrator::App["target.rom"].relations[:migrator_links].changeset(:create, session: legacy_property[:property_uuid],  target_id: target_chain_holder[:id], legacy_id: legacy_user_id, type: 'user').commit

        # Create the merchant_gateway in target repo along with the link
        legacy_merchant_gateway_attributes = legacy_merchant_gateway.dup
        merchant_gateway_id = legacy_merchant_gateway_attributes.delete(:id)
        legacy_merchant_gateway_attributes[:created_by] = target_chain_holder[:id]
        @target_merchant_gateway = ::Migrator::App["target.rom"].relations[:merchant_gateways].changeset(:create, legacy_merchant_gateway_attributes).commit
        ::Migrator::App["target.rom"].relations[:migrator_links].changeset(:create, session: legacy_property[:property_uuid],  target_id: target_merchant_gateway[:id], legacy_id: merchant_gateway_id, type: 'merchant_gateway').commit
      end

      # Migrate ota_tokens (depends on user, property)
      def migrate_ota_tokens
        ::Migrator::App["legacy.rom"].relations[:ota_tokens].where(property_uuid: target_property[:property_uuid]).each do |legacy_ota_token|
          legacy_ota_token_id = legacy_ota_token.delete(:id)
          target_ota_token = ::Migrator::App["target.rom"].relations[:ota_tokens].changeset(:create, legacy_ota_token).commit
          ::Migrator::App["target.rom"].relations[:migrator_links].changeset(:create, session: legacy_property[:property_uuid],  target_id: target_ota_token[:id], legacy_id: legacy_ota_token_id, type: 'ota_token').commit
        end
      end

      def migrate_property
        # Create the property in target repo along with the link
        legacy_property_attributes = legacy_property.dup
        legacy_property_attributes[:payment_gateway_id] = target_merchant_gateway[:id]
        legacy_property_attributes[:created_by] = target_chain_holder[:id]
        legacy_property_id = legacy_property_attributes.delete(:id)

        # Create the property in target repo
        @target_property = ::Migrator::App["target.rom"].relations[:properties].changeset(:create, legacy_property_attributes).commit
        ::Migrator::App["target.rom"].relations[:migrator_links].changeset(:create, session: legacy_property[:property_uuid],  target_id: target_property[:id], legacy_id: legacy_property_id, type: 'property').commit

        # Create acl_modules for that property
        ::Migrator::App["target.rom"].relations[:acl_modules].each do |target_acl_module|
          ::Migrator::App["target.rom"].relations[:acl_property_modules].changeset(:create, property_id: target_property[:id], acl_module_id: target_acl_module[:id]).commit
        end
      end

      def migrate_property_user
        # Migrate role
        target_role = ::Migrator::App["target.rom"].relations[:roles].changeset(:create, name: 'Merchant', created_by: target_chain_holder[:id], has_property_full_access: true).commit

        # Migrate user_role_property_mappings (depends on user, role, property)
        ::Migrator::App["target.rom"].relations[:user_role_property_mappings].changeset(:create, user_id: target_chain_holder[:id], role_id: target_role[:id], property_id: target_property[:id]).commit
      end

      # Migrate system_logs (depends on user, property, reference)
      def migrate_system_logs
        ::Migrator::App["legacy.rom"].relations[:system_logs].where(property_uuid: target_property[:property_uuid]).each do |legacy_system_log|
          legacy_system_log_id = legacy_system_log.delete(:id)
          target_system_log = ::Migrator::App["target.rom"].relations[:system_logs].changeset(:create, legacy_system_log).commit
          ::Migrator::App["target.rom"].relations[:migrator_links].changeset(:create, session: legacy_property[:property_uuid],  target_id: target_system_log[:id], legacy_id: legacy_system_log_id, type: 'system_log').commit
        end
      end

      # Migrate terminals (depends on gateway)
      def migrate_terminals
        ::Migrator::App["legacy.rom"].relations[:terminals].where(gateway_id: legacy_merchant_gateway[:id]).each do |legacy_terminal|
          legacy_terminal_id = legacy_terminal.delete(:id)
          legacy_terminal[:gateway_id] = target_merchant_gateway[:id]
          target_terminal = ::Migrator::App["target.rom"].relations[:terminals].changeset(:create, legacy_terminal).commit
          ::Migrator::App["target.rom"].relations[:migrator_links].changeset(:create, session: legacy_property[:property_uuid],  target_id: target_terminal[:id], legacy_id: legacy_terminal_id, type: 'terminal').commit
        end
      end

      # Migrate webhook_transaction_logs (depends on property, user, reference)
      def migrate_webhook_transaction_logs
        ::Migrator::App["legacy.rom"].relations[:webhook_transaction_logs].where(property_uuid: target_property[:property_uuid]).each do |legacy_webhook_transaction_log|
          legacy_webhook_transaction_log_id = legacy_webhook_transaction_log.delete(:id)
          target_webhook_transaction_log = ::Migrator::App["target.rom"].relations[:webhook_transaction_logs].changeset(:create, legacy_webhook_transaction_log).commit
          ::Migrator::App["target.rom"].relations[:migrator_links].changeset(:create, session: legacy_property[:property_uuid],  target_id: target_webhook_transaction_log[:id], legacy_id: legacy_webhook_transaction_log_id, type: 'webhook_transaction_log').commit
        end
      end

      def target_chain_holder
        # This should get set on creation, but if not, we can attempt to load the new user by the legacy chain holder uuid
        @target_chain_holder ||= ::Migrator::App["target.rom"].relations[:users].where(user_uuid: legacy_property[:chain_holder_id]).one
      end

      def target_merchant_gateway
        # This should get set on creation, but if not, we can attempt to load the new merchant gateway by the legacy UUID
        @target_merchant_gateway ||= ::Migrator::App["target.rom"].relations[:merchant_gateways].where(gateway_uuid: legacy_merchant_gateway[:gateway_uuid]).one
      end

      def target_property
        # This should get set on creation, but if not, we can attempt to load the new property by the legacy UUID
        @target_property ||= ::Migrator::App["target.rom"].relations[:properties].where(property_uuid: legacy_property[:property_uuid]).one
      end
    end
  end
end