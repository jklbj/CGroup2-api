# frozen_string_literal: true

require 'roda'
require_relative './app'

module CGroup2
  # Web controller for CGroup2 API
  class Api < Roda

    route('accounts') do |routing|
      @account_route = "#{@api_root}/accounts"

      routing.on String do |account_name|    
        # GET api/v1/accounts/[name]
        routing.get do
          account = GetAccountQuery.call(
            requestor: @auth_account, username: account_name
          )
          account.to_json
        rescue GetAccountQuery::ForbiddenError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => error
          puts "GET ACCOUNT ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API Server Error' }.to_json
        end
      end

      # POST api/v1/accounts
      routing.post do
        new_data = SignedRequest.new(Api.config).parse(request.body.read)
        new_account = Account.new(new_data)
        raise('Could not save account') unless new_account.save

        response.status = 201
        response['Location'] = "#{@usr_route}/#{new_account.name}"
        { message: 'Account saved', data: new_account }.to_json
      rescue Sequel::MassAssignmentRestriction
        routing.halt 400, { message: 'Illegal Request' }.to_json
      rescue SignedRequest::VerificationError
        routing.halt 403, { message: 'Must sign request' }.to_json
      rescue StandardError => e
        puts e.inspect
        routing.halt 500, { message: e.message }.to_json
      end
    end
  end
end
          