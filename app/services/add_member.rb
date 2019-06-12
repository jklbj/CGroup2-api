# frozen_string_literal: true

module CGroup2
  # Add a member to another owner's existing group
  class AddMember
     # Error for owner cannot be member
     class ForbiddenError < StandardError
      def message
        'You are not allowed to invite that person as member'
      end
    end

    def self.call(account:, group:, member_email:)
      invitee = Account.first(email: member_email)
      policy = MemberRequestPolicy.new(group, account, invitee)
      raise ForbiddenError unless policy.can_invite?

      group.add_member(invitee)
      invitee
    end
  end
end
