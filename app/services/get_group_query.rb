# frozen_string_literal: true

module CGroup2
  # Add a member to another owner's existing group
  class GetGroupQuery
    # Error for owner cannot be member
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that group'
      end
    end

    # Error for cannot find a group
    class NotFoundError < StandardError
      def message
        'We could not find that group'
      end
    end

    def self.call(account:, group:)
      raise NotFoundError unless group
      policy = GroupPolicy.new(account, group)
      raise ForbiddenError unless policy.can_view?

      group.full_details.merge(policies: policy.summary)
    end
  end
end
