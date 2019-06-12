# frozen_string_literal: true

require 'roda'
require_relative './app'

# rubocop:disable Metrics/BlockLength
module CGroup2
  # Web controller for CGroup2 API
  class Api < Roda
    route('calendar_events') do |routing|
      @calendar_route = "#{@api_root}/calendar_events"

      routing.on String do |cal_id|
        # GET api/v1/calendar_events/[ID]
        routing.get do
          cale = Calendar.first(calendar_id: cal_id)
          cale ? cale.to_json : raise('Calendar event not found')
        rescue StandardError => e
          routing.halt 404, { message: e.message }.to_json
        end
      end

      #GET api/v1/calendar_events
      routing.get do
        calendar_events = @auth_account.calendar_events
        JSON.pretty_generate(data: calendar_events)
      rescue StandardError
        routing.halt 403, { message: 'Could not find any calendar events'}.to_json
      end

      #POST api/v1/calendar_events
      routing.post do
        new_data = JSON.parse(routing.body.read)
        new_cale = Calendar.new(new_data)
        raise('Could not save calendar event') unless new_cale.save

        response.status = 201
        response['Location'] = "#{@calendar_route}/#{new_cale.calendar_id}"
        { message: 'Calendar events saved', data: new_cale }.to_json
      rescue Sequel::MassAssignmentRestriction
        routing.halt 400, { message: 'Illegal Request' }.to_json
      rescue StandardError => e
        routing.halt 500, { message: e.message }.to_json
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
