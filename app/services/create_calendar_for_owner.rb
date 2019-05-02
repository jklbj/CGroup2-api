# frozen_string_literal: true

module CGroup2
  # Service object to create new group for a project
  class CreateCalendarForOwner
    def self.call(owner_id:, calendar_data:)
      Account.find(account_id: owner_id)
             .add_calendar(calendar_data)
    end
  end
end
