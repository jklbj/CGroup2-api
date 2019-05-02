# frozen_string_literal: true

module CGroup2
  # Service object to create new group for a project
  class CreateGroupForOwner
    def self.call(owner_id:, group_data:)
      Account.find(account_id: owner_id)
             .add_group(group_data)
    end
  end
end
