# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :migrator_links do
      primary_key :id
      column :session, String, null: false
      column :target_id, Integer, null: false
      column :legacy_id, Integer, null: false
      column :type, String, null: false
      column :duplicate, FalseClass, null: false, default: false
    end
  end
end
