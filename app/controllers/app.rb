# frozen_string_literal: true
require 'roda'
require 'json'

require_relative '../models/event'

module CGroup
  # Web controller for Fibuy API
  class Api < Roda
    plugin :environments
    plugin :halt

    configure do
      Event.setup
    end

    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'FibuyAPI up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          routing.on 'events' do
            # GET api/v1/events/[id]
            routing.get String do |id|
                Event.find(id).to_json
            rescue StandardError
              routing.halt 404, { message: 'Event not found' }.to_json
            end

            # GET api/v1/events
            routing.get do
              output = { event_ids: Event.all }
              JSON.pretty_generate(output)
            end

            # POST api/v1/events
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_ev = Event.new(new_data)

              if new_ev.save
                response.status = 201
                { message: 'Event saved', id: new_ev.id }.to_json
              else
                routing.halt 400, { message: 'Could not save event' }.to_json
              end
            end
          end
        end
      end
    end
  end
end