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
          usr = Account.first(name: account_name)
          usr ? usr.to_json : raise('Account not found')
        rescue StandardError => error
          routing.halt 404, { message: error.message }.to_json
        end
      end

      # POST api/v1/accounts
      routing.post do
        new_data = JSON.parse(routing.body.read)
        new_account = Account.new(new_data)
        raise('Could not save project') unless new_account.save

        response.status = 201
        response['Location'] = "#{@usr_route}/#{new_account.name}"
        { message: 'Account saved', data: new_account }.to_json
      rescue Sequel::MassAssignmentRestriction
        routing.halt 400, { message: 'Illegal Request' }.to_json
      rescue StandardError => e
        puts e.inspect
        routing.halt 500, { message: e.message }.to_json
      end
    end
  end
end
          