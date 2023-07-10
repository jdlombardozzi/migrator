module Migrator
  module Migrate
    class TruncateProperty
      attr_reader :property, :datasets

      DATASETS = %i[webhook_transaction_logs system_logs ota_tokens iframe_txn_logs terminals gateway_reference_numbers user_role_property_mappings properties merchant_gateways users].freeze

      class << self
        # @param [String] uuid The uuid of the property to migrate
        def call(uuid, dataset = :all)
          new(uuid, dataset).call
        end
      end

      # @param [String] uuid The uuid of the property to migrate
      # @param [Symbol] dataset The dataset to truncate, defaults to :all
      def initialize(uuid, dataset = :all)
        @property = ::Migrator::App["target.rom"].relations[:properties].where(property_uuid: uuid).one
        @datasets = if dataset == :all
                      DATASETS
                    elsif DATASETS.include?(dataset.to_sym)
                      [dataset.to_sym]
                    else
                      raise "Invalid dataset: #{dataset}"
                    end
      end

      def call
        # Remove all data from the target property. Useful if you want start over a migration.
        datasets.each do |dataset|
          pre_hook = "pre_truncate_#{dataset}".to_sym
          send(pre_hook) if respond_to?(pre_hook, true)

          relation_with_filter(dataset).delete

          type = dataset == :properties ? 'property' : dataset.to_s.chomp('s')
          ::Migrator::App["target.rom"].relations[:migrator_links].where(session: property[:property_uuid], type: type).delete

          post_hook = "post_truncate_#{dataset}".to_sym
          send(post_hook) if respond_to?(post_hook, true)
        end
      end

      private

      # We need the reference numbers in order to truncate authorization_adjustment_logs and standalone_refund_logs
      def pre_truncate_gateway_reference_numbers
        # TODO: Batch this
        relation_with_filter(:gateway_reference_numbers).each do |gateway_reference_number|
          ::Migrator::App["target.rom"].relations[:authorization_adjustment_logs].where(reference_number: gateway_reference_number[:reference_number]).delete
          ::Migrator::App["target.rom"].relations[:standalone_refund_logs].where(reference_number: gateway_reference_number[:reference_number]).delete
        end
      end


      def pre_truncate_properties
        ::Migrator::App["target.rom"].relations[:acl_property_modules].where(property_id: property[:id]).delete
      end

      def pre_truncate_users
        relation_with_filter(:users).each do |user|
          ::Migrator::App["target.rom"].relations[:roles].where(created_by: user[:id]).delete
          ::Migrator::App["target.rom"].relations[:user_role_property_mappings].where(user_id: user[:id]).delete
        end
      end

      def relation_with_filter(name)
        relation = ::Migrator::App["target.rom"].relations[name]

        case name.to_s
        when 'merchant_gateways'
          relation.where(id: property[:payment_gateway_id])
        when 'terminals'
          relation.where(gateway_id: merchant_gateway[:id])
        when 'gateway_reference_numbers'
          relation.where(gateway_uuid: merchant_gateway[:gateway_uuid])
        when 'user_role_property_mappings'
          relation.where(property_id: property[:id])
        when 'users'
          relation.where(id: merchant_gateway[:created_by])
        else
          relation.where(property_uuid: property[:property_uuid])
        end
      end

      def merchant_gateway
        @merchant_gateway ||= ::Migrator::App["target.rom"].relations[:merchant_gateways].where(id: property[:payment_gateway_id]).one
      end
    end
  end
end