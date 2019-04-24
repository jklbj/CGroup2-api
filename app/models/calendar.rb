# frozen_string_literal: true

require 'json'
require 'sequel'

module CGroup2 
    # Models a secret document
    class Calendar < Sequel::Model
        many_to_one :user

        plugin :timestamps
        plugin :whitelist_security
        set_allowed_columns :title, :description, :description, :event_start_at, :event_end_at

        # Secure getters and setters
        def title
            SecureDB.decrypt(title_secure)
        end
    
        def title=(plaintext)
            self.title_secure = SecureDB.encrypt(plaintext)
        end

        def description
            SecureDB.decrypt(description_secure)
        end
    
        def description=(plaintext)
            self.description_secure = SecureDB.encrypt(plaintext)
        end

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
            