# frozen_string_literal: true
require 'roda'
require 'json'

module CGroup2
  # Web controller for CGroup2 API
  class Api < Roda
    plugin :halt
		
		route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'CGroupAPI up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      routing.on @api_root do
				routing.on 'users' do
					@usr_route = "#{@api_root}/users"

					routing.on String do |user_id|
						
						routing.on 'calendar_events' do
							@cal_route = "#{@api_root}/users/#{user_id}/calendar_events"
							# GET api/v1/users/[user_id]/calendar_events/[calendar_id]
							routing.get String do |cal_id|
							
								cal = Calendar.where(user_id: user_id, calendar_id: cal_id).first
					      cal ? cal.to_json : raise('Calender event not found')
							rescue StandardError => e
								routing.halt 404, { message: e.message }.to_json
							end
						

							# GET api/v1/users/[user_id]/calender_events
							routing.get do
								output = { calendar_ids: Calendar.all }
								JSON.pretty_generate(output)
							end

						  # POST api/v1/users/[user_id]/calender_events
							routing.post do
								new_data = JSON.parse(routing.body.read)
								usr = User.first(user_id: user_id)
								new_event = usr.add_calendar(new_data)

							
								response.status = 201
								response['Location'] = "#{@cal_route}/#{new_event.calendar_id}"
								{ message: 'calendar event saved', data: new_event }.to_json
								
							rescue Sequel::MassAssignmentRestriction
                routing.halt 400, { message: 'Illegal Request' }.to_json
							rescue StandardError
                routing.halt 500, { message: 'Database error' }.to_json
							end
						end
				
						routing.on 'group_events' do
							@grp_route = "#{@api_root}/users/#{user_id}/group_events"
							# GET api/v1/users/[user_id]/group_events/[group_id]
							
							routing.get String do |grp_id|
								
								grp = Group.where(user_id: user_id, group_id: grp_id).first
								
					      grp ? grp.to_json : raise('Group event not found')
							rescue StandardError => e
								routing.halt 404, { message: e.message }.to_json
							end
						

							# GET api/v1/users/[user_id]/group_events
							routing.get do
								output = { group_ids: Group.all }
								JSON.pretty_generate(output)
							end

						  # POST api/v1/users/[user_id]/group_events
							routing.post do
								new_data = JSON.parse(routing.body.read)
								usr = User.first(user_id: user_id)
								new_event = usr.add_group(new_data)
								raise 'Could not save group event' unless new_event
								
								response.status = 201
								response['Location'] = "#{@grp_route}/#{new_event.group_id}"
								{ message: 'group event saved', data: new_event }.to_json
							rescue Sequel::MassAssignmentRestriction
                routing.halt 400, { message: 'Illegal Request' }.to_json	
							rescue StandardError
                routing.halt 500, { message: 'Database error' }.to_json
							end
						end

						# GET api/v1/users/[user_id]
						routing.get do
							usr = User.first(user_id: user_id)
							usr ? usr.to_json : raise('User not found')
						rescue StandardError => error
							routing.halt 404, { message: error.message }.to_json
						end
					end
						
					# GET api/v1/users
					routing.get do
						output = { data: User.all }
						JSON.pretty_generate(output)
					rescue StandardError
						routing.halt 404, { message: 'Could not find users' }.to_json
					end

					# POST api/v1/users
					routing.post do
						new_data = JSON.parse(routing.body.read)
						new_user = User.new(new_data)
						raise('Could not save project') unless new_user.save

						response.status = 201
            response['Location'] = "#{@usr_route}/#{new_user.user_id}"
            { message: 'User saved', data: new_user }.to_json
					rescue StandardError => error
						routing.halt 400, { message: error.message }.to_json
					end
				end
				
				routing.on 'group_events' do
					@group_route = "#{@api_root}/group_events"
					
					#GET api/v1/group_events
					routing.get do
						output = { group_ids: Group.all}
						JSON.pretty_generate(output)
					end
				end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength