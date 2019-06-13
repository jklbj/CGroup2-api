# frozen_string_literal: true

module CGroup2
  # Policy to determine if account can view a group
  class GroupPolicy
    #Scope of group policies
    class AccountScope
      def initialize(current_account, target_account = nil)
        target_account ||= current_account
        @full_scope = all_groups(target_account)
        @current_account = current_account
        @target_account = target_account
      end

      def viewable
        if @current_account == @target_account
          @full_scope
        else
          @full_scope.select do |grp|
            includes_members?(grp, @current_account)
          end
        end
      end

      private

      def all_groups(account)
        account.groups + account.participations
      end

      def includes_members?(group, account)
        group.members.include? account
      end
    end
  end
end
