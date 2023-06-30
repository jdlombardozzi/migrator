module Migrator
  module Migrate
    class CopyProperty
      # @param [String] property_uuid The UUID of the legacy property to copy.
      def call(property_uuid:)
        # Validate/load property from legacy provider

        # Create property in new provider (copy all attributes except id)

        # Add a link to the legacy property in the new provider with the id of each provider

        # Trigger all relation data migrations
      end
    end
  end
end