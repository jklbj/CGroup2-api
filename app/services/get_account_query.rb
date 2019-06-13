# frozen_string_literal: true

module CGroup2
  # Error if requesting to see forbidden account
  class GetAccountQuery
    class ForbiddenError < StandardError
      def message
        'You are not allowed to acces the project'
      end
    end

    def self.call(requestor:, username:)
      account = Account.first(username: username)

      policy = AccountPolicy.new(requestor, account)
      policy.can_view? ? account : raise(ForbiddenError)
    end
  end
end
            