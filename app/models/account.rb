# frozen_string_literal: true

require 'json'
require 'sequel'

module CGroup2
  # Models a project
  class account < Sequel::Model
    one_to_many :groups
    one_to_many :calendars
    plugin :association_dependencies, groups: :destroy, calendars: :destroy

    plugin :timestamps

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
