# frozen_string_literal: true

require 'json'
require 'sequel'
require_relative './password'

module CGroup2
  # Models a project
  class Account < Sequel::Model
    one_to_many :groups
    one_to_many :calendars
    plugin :association_dependencies, groups: :destroy, calendars: :destroy

    plugin :timestamps, update_on_create: true
    plugin :whitelist_security
    set_allowed_columns :account, :sex, :name, :email, :password, :birth

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = CGroup2::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end 

    # rubocop:disable MethodLength
    def to_json(options = {})
      JSON(
        {
          type: 'account',
          attributes: {
            account_id: account_id,
            name: name,
            sex: sex,
            email: email,
            account: account,
            birth: birth
          }
        }, options
      )
    end
    # rubocop:enable MethodLength
  end
end
