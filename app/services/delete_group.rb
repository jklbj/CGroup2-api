# frozen_string_literal: true

module CGroup2
    # Romove a group to another owner's existing group
    class DeleteGroup
      # Error for owner cannot be member
      class ForbiddenErroor < StandardError
        def message
          'You are not allowed to delete that group'
        end
      end
  
      def self.call(req_username:, group_id:)
        account = Account.first(name: req_username)
        group = Group.first(group_id: group_id)
        
        policy = OwnerRequestPolicy.new(group, account)
        raise ForbiddenErroor unless policy.can_delete_group?
  
        account.remove_group(group)
        group
      end
    end
  end
  