# frozen_string_literal: true

module CGroup2
  # Add a member to another owner's existing group
  class GetGroupQuery
    # Error for cannot find a group
    class NotFoundError < StandardError
      def message
        'We could not find that group'
      end
    end

    def self.call(account:, group:)
      raise NotFoundError unless group
      policy = GroupPolicy.new(account, group)

      group.full_details.merge(policies: policy.summary)
    end
  end
end
