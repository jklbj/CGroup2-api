# frozen_string_literal: true

module CGroup2
  # Policy to determine if an account can view a particular project
  class GroupPolicy
    def initialize(account, group)
      @account = account
      @group = group
    end

    def can_view?
      true
    end

    def can_view_members?
      account_is_owner? || account_is_member?
    end

    def can_edit?
      account_is_owner?
    end

    def can_delete?
      account_is_owner?
    end

    def can_leave?
      account_is_member?
    end

    def can_add_members?
      account_is_owner?
    end

    def can_remove_members?
      account_is_owner?
    end

    def can_join?
      (not (account_is_owner? or account_is_member?)) && members_are_enough?
    end

    def summary
      {
        can_view: can_view?,
        can_view_members: can_view_members?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_leave: can_leave?,
        can_add_members: can_add_members?,
        can_remove_members: can_remove_members?,
        can_join: can_join?
      }
    end

    private

    def account_is_owner?
      @group.account == @account
    end

    def account_is_member?
      @group.members.include?(@account)
    end

    def members_are_enough?
      (@group.members.count+1) <= @group.limit_number
    end
  end
end
