# frozen_string_literal: true

module CGroup2
  # Policy to determine if an account can view a particular calendar events
  class CalendarPolicy
    def initialize(account, calendar_event)
      @account = account
      @calendar_event = calendar_event
    end

    def can_view?
      account_is_owner?
    end

    def summary
      {
        can_view: can_view?
      }
    end

    private

    def account_is_owner?
      @calendar_event.account == @account
    end
  end
end
