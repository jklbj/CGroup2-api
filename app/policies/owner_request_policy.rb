# frozen_string_literal: true

module CGroup2
  # Policy to determine if an account can view a particular group
  class OwnerRequestPolicy
    def initialize(group, requestor_account)
      @group = group
      @requestor_account = requestor_account
      @requestor = GroupPolicy.new(requestor_account, group)
    end

    def can_delete_group?
      @requestor.can_delete?
    end
  end
end
