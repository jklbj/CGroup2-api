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
        calendar_events = @auth_account.calendars
        JSON.pretty_generate(data: calendar_events)
      rescue StandardError => e
        puts "error message: #{e}"
        routing.halt 403, { message: 'Could not find any calendar events'}.to_json
      end

      #POST api/v1/calendar_events
      routing.post do
        auth_request = JsonRequestBody.parse_symbolize(request.body.read)
        new_cale = AuthorizeSso.new(@auth_account, Api.config)
                    .call(auth_request[:access_token])
        response.status = 201
        response['Location'] = "#{@calendar_route}"
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
