# frozen_string_literal: true

require 'json'
require 'sequel'

module CGroup2 
  # Models a secret document
  class Group < Sequel::Model
    many_to_one :account, class: :'CGroup2::Account'

    many_to_many :members,
                 class: :'CGroup2::Account',
                 join_table: :accounts_groups,
                 left_key: :group_id, right_key: :member_id

    plugin :association_dependencies,
    members: :nullify

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :title, :description, :member_id, :limit_number, :due_at, :event_start_at, :event_end_at

    # Secure getters and setters
    def title
        SecureDB.decrypt(title_secure).encoding
    end

    def title=(plaintext)
        self.title_secure = SecureDB.encrypt(plaintext)
    end

    def description
        SecureDB.decrypt(description_secure).encoding
    end

    def description=(plaintext)
        self.description_secure = SecureDB.encrypt(plaintext)
    end 

    # rubocop:disable MethodLength
    def to_h(options = {})
      {
        type: 'group',
        attribute: {
          group_id: group_id,
          title: title,
          description: description,
          limit_number: limit_number,
          due_at: due_at,
          event_start_at: event_start_at,
          event_end_at: event_end_at            
        }        
      }
    end
    # rubocop:enable MethodLength

    def full_details
      to_h.merge(
        relationships: {
          account: account,
          members: members
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
            