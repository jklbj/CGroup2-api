# frozen_string_literal: true

module CGroup2
  # Add a member to another owner's existing group
  class RemoveMember
    # Error for owner cannot be member
    class ForbiddenErroor < StandardError
      def message
        'You are not allowed to remove that person'
      end
    end

    def self.call(req_username:, member_email:, group_id:)
      account = Account.first(username: username)
      group = Group.first(id: group_id)
      member = Account.first(email: member_email)

      policy = MemberRequestPolicy(group, account, member)
      raise ForbiddenErroor unless policy.can_remove?

      group.remove_member(member)
      member
    end
  end
end
