# frozen_string_literal: true

module CGroup2
  # Add a collaborator to another owner's existing calendar event
  class GetCalendarQuery
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that calendar event'
      end
    end

    # Error for cannot find a calendar event
    class NotFoundError < StandardError
      def message
        'We could not find that calendar event'
      end
    end

    def self.call(account:, calendar_event:)
      raise NotFoundError unless calendar_event

      policy = CalendarPolicy.new(account, calendar_event)
      raise ForbiddenError unless policy.can_veiw?

      calendar_event
    end
  end
end
