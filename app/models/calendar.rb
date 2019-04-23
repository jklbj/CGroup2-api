# frozen_string_literal: true

require 'json'
require 'sequel'

module CGroup2 
    # Models a secret document
    class Calendar < Sequel::Model
        many_to_one :user

        plugin :timestamps
        plugin :whitelist_security
        set_allowed_columns :title, :relative_path, :description, :content
        set_allowed_columns :description, :relative_path, :description, :content
        set_allowed_columns :event_start_at, :relative_path, :description, :content
        set_allowed_columns :event_end_at, :relative_path, :description, :content

        # rubocop:disable MethodLength
        def to_json(options = {})
            JSON(
                {
                    data: {
                        type: 'calendar',
                        attribute: {
                            calendar_id: calendar_id,
                            title: title,
                            description: description,
                            event_start_at: event_start_at,
                            event_end_at: event_end_at
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
            