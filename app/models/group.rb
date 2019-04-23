# frozen_string_literal: true

require 'json'
require 'sequel'

module CGroup2 
    # Models a secret document
    class Group < Sequel::Model
        many_to_one :user

        plugin :timestamps
        plugin :whitelist_security
        set_allowed_columns :title, :relative_path, :description, :content
        set_allowed_columns :description, :relative_path, :description, :content
        set_allowed_columns :member_id, :relative_path, :description, :content
        set_allowed_columns :limit_number, :relative_path, :description, :content
        set_allowed_columns :due_at, :relative_path, :description, :content
        set_allowed_columns :event_start_at, :relative_path, :description, :content
        set_allowed_columns :event_end_at, :relative_path, :description, :content

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
            