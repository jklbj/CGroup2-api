# frozen_string_literal: true

require 'roda'
require_relative './app'

module CGroup2
  # Web controller for CGroup2 API
  class Api < Roda

    route('accounts') do |routing|
      @account_route = "#{@api_root}/accounts"

      routing.on String do |account_name|

        routing.on 'calendar_events' do
          @cal_route = "#{@api_root}/accounts/#{account_name}/calendar_events"
          # GET api/v1/accounts/[account_name]/calendar_events/[calendar_id]
          routing.get String do |cal_id|
            acc_id = Account.where(name: account_name).first.account_id
            cal = Calendar.where(account_id: acc_id, calendar_id: cal_id).first
            cal ? cal.to_json : raise('Calender event not found')
          rescue StandardError => e
            routing.halt 404, { message: e.message }.to_json
          end
        

          # GET api/v1/accounts/[account_name]/calender_events
          routing.get do
            output = { calendar_ids: Calendar.all }
            JSON.pretty_generate(output)
          end

          # POST api/v1/accounts/[account_name]/calender_events
          routing.post do
            new_data = JSON.parse(routing.body.read)
            usr = Account.first(name: account_name)
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
          @grp_route = "#{@api_root}/accounts/#{account_name}/group_events"
          # GET api/v1/accounts/[account_name]/group_events/[group_id]
          
          routing.get String do |grp_id|
            acc_id = Account.where(name: account_name).first.account_id
            grp = Group.where(account_id: acc_id, group_id: grp_id).first
            grp ? grp.to_json : raise('Group event not found')
          rescue StandardError => e
            routing.halt 404, { message: e.message }.to_json
          end
        

          # GET api/v1/accounts/[account_name]/group_events
          routing.get do
            output = { group_ids: Group.all }
            JSON.pretty_generate(output)
          end

          # POST api/v1/accounts/[account_name]/group_events
          routing.post do
            new_data = JSON.parse(routing.body.read)
            usr = Account.first(name: account_name)
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

        # GET api/v1/accounts/[name]
        routing.get do
          usr = Account.first(name: account_name)
          usr ? usr.to_json : raise('Account not found')
        rescue StandardError => error
          routing.halt 404, { message: error.message }.to_json
        end
      end

      # GET api/v1/accounts
      routing.get do
        output = { data: Account.all }
        JSON.pretty_generate(output)
      rescue StandardError
        routing.halt 404, { message: 'Could not find accounts' }.to_json
      end

      # POST api/v1/accounts
      routing.post do
        new_data = JSON.parse(routing.body.read)
        puts "routing body: #{new_data}"
        new_account = Account.new(new_data)
        puts "gooooooooooooooood"
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
          