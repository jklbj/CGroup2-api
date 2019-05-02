# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:calendars) do
      primary_key :calendar_id
      foreign_key :account_id, table: :accounts

      String :title_secure, null: false
      String :description_secure, text: true

      DateTime :event_start_at
      DateTime :event_end_at
      DateTime :created_at                  #blacklist
      DateTime :updated_at                  #blacklist

      unique [:account_id, :calendar_id]
    end
  end
end
