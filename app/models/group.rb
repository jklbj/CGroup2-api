# frozen_string_literal: true

require 'json'
require 'sequel'

module CGroup2 
    # Models a secret document
    class Group < Sequel::Model
        many_to_one :accounts

        plugin :timestamps
        plugin :whitelist_security
        set_allowed_columns :title, :description, :member_id, :limit_number, :due_at, :event_start_at, :event_end_at

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

        def member_id
            SecureDB.decrypt(member_id_secure)
        end
    
        def member_id=(plaintext)
            self.member_id_secure = SecureDB.encrypt(plaintext)
        end

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
                            event_start_at: event_start_at,
                            event_end_at: event_end_at,
                            member_id: member_id
                        }
                    },
                    include: {
                        account: account
                    }           
                }, options
            )
        end
        # rubocop:enable MethodLength
    end
end
            