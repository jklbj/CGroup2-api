# frozen_string_literal: true

require 'json'
require 'sequel'

module CGroup2 
    # Models a secret document
    class Group < Sequel::Model
        many_to_one :user

        plugin :timestamps
        plugin :whitelist_security
        set_allowed_columns :title, :description, :member_id, :limit_number, :due_at, :event_start_at, :event_end_at

        # rubocop:disable MethodLength
        def to_json(options = {})
            JSON(
                {
                    data: {
                        type: 'group',
                        attribute: {
                            group_id: group_id,
                            title: title,
                            description: description,
                            limit_number: limit_number,
                            due_at: due_at,
                            member_id: member_id
                        }
                    },
                    include: {
                        user: user
                    }           
                }, options
            )
        end
        # rubocop:enable MethodLength
    end
end
            