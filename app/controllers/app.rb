# frozen_string_literal: true
require 'roda'
require 'json'

require_relative '../models/calendar'

module CGroup2
  # Web controller for CGroup2 API
  class Api < Roda
    plugin :environments
    plugin :halt

    configure do
      Calendar.setup
    end

    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'CGroupAPI up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          routing.on 'calendar_events' do
            # GET api/v1/calender_events/[id]
            routing.get String do |id|
                Calendar.find(id).to_json
            rescue StandardError
              routing.halt 404, { message: 'Calendar event not found' }.to_json
            end

            # GET api/v1/calender_events
            routing.get do
              output = { calendar_event_ids: Calendar.all }
              JSON.pretty_generate(output)
            end

            # POST api/v1/calender_events
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_ev = Calendar.new(new_data)

              if new_ev.save
                response.status = 201
                { message: 'Calendar event saved', calendar_id: new_ev.calendar_id }.to_json
              else
                routing.halt 400, { message: 'Could not save calendar event' }.to_json
              end
            end
          end
        end
      end
    end
  end
end