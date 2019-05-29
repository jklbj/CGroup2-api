# frozen_string_literal: true

require 'roda'
require_relative './app'

# rubocop:disable Metrics/BlockLength
module CGroup2
  # Web controller for CGroup2 API
  class Api < Roda
    route('group_events') do |routing|
      @group_route = "#{@api_root}/group_events"
      
      routing.get String do |grp_id|
        #GET api/v1/group_events/[grp_id]
        grp = Group.where(group_id: grp_id).first
        grp ? grp.to_json : raise('Group event not found')
      rescue StandardError => e
        routing.halt 404, { message: e.message }.to_json
      end

      #GET api/v1/group_events
      routing.get do
        account = Account.first(name: @auth_account['name'])
        group_events = account.group_events
        JSON.pretty_generate(data: group_events)
      rescue
        routing.halt 403, { message: 'Could not find any group events'}.to_json
      end

      #POST api/v1/group_events
      routing.post do
        new_data = JSON.parse(routing.body.read)
        new_grpe = Group.new(new_data)
        raise('Could not save group event') unless new_grpe.save

        response.status = 201
        response['Location'] = "#{@group_route}/#{new_grpe.group_id}"
        { message: 'Group events saved', data: new_grpe }.to_json
      rescue Sequel::MassAssignmentRestriction
        routing.halt 400, { message: 'Illegal Request' }.to_json
      rescue StandardError => e
        routing.halt 500, { message: e.message }.to_json
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength