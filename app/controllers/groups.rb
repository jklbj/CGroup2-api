# frozen_string_literal: true

require 'roda'
require_relative './app'

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
        output = { group_ids: Group.all}
        JSON.pretty_generate(output)
      end
    end
  end
end
