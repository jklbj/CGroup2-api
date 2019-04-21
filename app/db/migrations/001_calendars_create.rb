# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:calendars) do
      primary_key :calendar_id
      foreign_key :user_id, table: :users

      String :title, null: false
      String :description, text: true

      DateTime :event_start_at
      DateTime :event_end_at
      DateTime :created_at
      DateTime :updated_at

      unique [:user_id, :calendar_id]
    end
  end
end
