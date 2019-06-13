# frozen_string_literal: true

module CGroup2
  # Policy to determine if an account can view a particular group
  class MemberRequestPolicy
    def initialize(group, requestor_account, target_account)
      @group = group
      @requestor_account = requestor_account
      @target_account = target_account
      @requestor = GroupPolicy.new(requestor_account, group)
      @target = GroupPolicy.new(target_account, group)
    end

    def can_invite?
      @target.can_join?
    end

    def can_remove?
      @requestor.can_remove_members? && target_is_member?
    end

    def can_leave?
      (@requestor_account == @target_account) && target_is_member?
    end

    private

    def target_is_member?
      @group.members.include?(@target_account)
    end
  end
end
