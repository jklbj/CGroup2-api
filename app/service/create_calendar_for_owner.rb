# frozen_string_literal: true

module CGroup2
  # Service object to create new group for a project
  class CreateCalendarForOwner
    def self.call(owner_id:, calendar_data:)
      Calendar.first(id: owner_id)
             .add_document(calendar_data)
    end
  end
end
