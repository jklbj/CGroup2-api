# frozen_string_literal: true

require 'json'
require 'sequel'
require_relative './password'

module CGroup2
  # Models a registered account
  class Account < Sequel::Model
    one_to_many :groups, class: :'CGroup2::Group', key: :account_id
    many_to_many :participations,
                 class: :'CGroup2::Group',
                 join_table: :accounts_groups,
                 left_key: :member_id, right_key: :group_id
    one_to_many :calendars, class: :'CGroup2::Calendar', key: :account_id
    plugin :association_dependencies, 
           groups: :destroy,
           participations: :nullify,
           calendars: :destroy

    plugin :timestamps, update_on_create: true
    plugin :whitelist_security
    set_allowed_columns :sex, :name, :email, :password, :birth

    def group_events
      groups
    end

    def calendar_events
      calendars
    end

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
            birth: birth
          }
        }, options
      )
    end
  end
end
