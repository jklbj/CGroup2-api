# frozen_string_literal: true

module CGroup2
  # Service object to Create new group for a project
  class CreateGroupForOwner
    def self.call(owner_id:, group_data:)
      Group.first(id: owner_id)
             .add_document(group_data)
    end
  end
end
