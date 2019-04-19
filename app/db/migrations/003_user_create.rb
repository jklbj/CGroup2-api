# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:users) do
      primary_key :user_id

      String :name, unique: true, null: false
      String :email, unique: true, null: false
      String :account, unique: true, null: false
      String :password, null: false
      Fixnum :sex, fixed: true, null: false

      Date :birth, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end