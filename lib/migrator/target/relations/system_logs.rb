module Migrator
  module Target
    module Relations
      class SystemLogs < ROM::Relation[:sql]
        schema(:system_logs, infer: true)
      end
    end
  end
end