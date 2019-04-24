# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:groups) do
      primary_key :group_id
      foreign_key :user_id, table: :users
      
      Integer :limit_number, null: false  

      String :title_secure, null: false
      String :description_secure, text: true
      String :member_id_secure
      
      DateTime :due_at
      DateTime :event_start_at
      DateTime :event_end_at
      DateTime :created_at                  #blacklist
      DateTime :updated_at                  #blacklist

      unique [:user_id, :group_id]
    end
  end
end
