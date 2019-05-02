# frozen_string_literal: true

require 'json'
require 'sequel'
require_relative './password'

module CGroup2
  # Models a project
  class account < Sequel::Model
    one_to_many :groups,
    one_to_many :calendars
    plugin :association_dependencies, groups: :destroy, calendars: :destroy

    plugin :timestamps, update_on_create: true

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = Credence::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end 

    # rubocop:disable MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'account',
            attributes: {
              account_id: account_id,
              name: name,
              sex: sex,
              email: email,
              account: account,
              password: password,
              birth: birth
            }
          }
        }, options
      )
    end
    # rubocop:enable MethodLength
  end
end
