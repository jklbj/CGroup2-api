# frozen_string_literal: true

module CGroup2
    # Add a member to another owner's existing group
    class LeaveGroup
      # Error for owner cannot be member
      class ForbiddenError < StandardError
        def message
          'You are not allowed to remove that person'
        end
      end
  
      def self.call(req_username:, member_email:, group_id:)
        account = Account.first(name: req_username)
        group = Group.first(group_id: group_id)
        member = Account.first(email: member_email)
  
        policy = MemberRequestPolicy.new(group, account, member)
        raise ForbiddenError unless policy.can_leave?
  
        group.remove_member(member)
        member
      end
    end
  end
  