# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:accounts) do
      primary_key :account_id

      String :name, unique: true, null: false
      String :email, unique: true, null: false
      String :account, unique: true, null: false
      String :password_digest, null: false
      Fixnum :sex, fixed: true, null: false

      Date :birth, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end