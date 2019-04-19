# frozen_string_literal: true

require 'json'
require 'sequel'

module CGroup2 
    # Models a secret document
    class Calendar < Sequel::Model
        many_to_one :user

        plugin :timestamps

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
            