# frozen_string_literal: true

require_relative './app'

# rubocop:disable Metrics/BlockLength
module CGroup2
  # Web controller for CGroup2 API
  class Api < Roda
    route('group_events') do |routing|
      unauthorized_message = { message: 'Unauthorized Request' }.to_json
      routing.halt(403, unauthorized_message) unless @auth_account

      @group_route = "#{@api_root}/group_events"
      routing.on String do |grp_id|
        @req_group = Group.first(group_id: grp_id) unless grp_id.eql? "all"

        #GET api/v1/group_events/[grp_id]
        routing.get do
          if grp_id.eql? "all"
            group = Group.all
          else
            group = GetGroupQuery.call(
              account: @auth_account, group: @req_group
            )
            
          end

          { data: group }.to_json
        rescue GetGroupQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetGroupQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "FIND GROUP ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end

        #DELETE api/v1/group_events/[grp_id]
        routing.delete do
          group = DeleteGroup.call(
            req_username: @auth_account.name,
            group_id: grp_id
          )

          { message: "#{group.title} deleted." }.to_json
        rescue DeleteGroup::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue StandardError
          routing.halt 500, { message: 'API server error' }.to_json
        end
          
        routing.on('members') do # rubocop:disable Metrics/BlockLength
          # PUT api/v1/group_events/[grp_id]/members
          routing.put do
            req_data = JSON.parse(routing.body.read)

            member = AddMember.call(
              account: @auth_account,
              group: @req_group,
              member_email: req_data['email']
            )

            { data: member }.to_json
          rescue AddMember::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end

          # DELETE api/v1/group_events/[grp_id]/members
          routing.delete do
            req_data = JSON.parse(routing.body.read)
            action = req_data['action']

            task_list = {
              'remove' => { service: RemoveMember,
                            message: 'Removed member from group' },
              'leave' => { service: LeaveGroup,
                            message: 'Leave group' }
            }

            task = task_list[action]
            member = task[:service].call(
              req_username: @auth_account.name,
              member_email: req_data['email'],
              group_id: grp_id
            )

            { message: "#{member.name} removed from group",
              data: member }.to_json
          rescue RemoveMember::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end
      end

      routing .is do
        #GET api/v1/group_events
        routing.get do
          group_events = GroupPolicy::AccountScope.new(@auth_account).viewable

          JSON.pretty_generate(data: group_events)
        rescue StandardError
          routing.halt 403, { message: 'Could not find any group events'}.to_json
        end

        #POST api/v1/group_events
        routing.post do
          new_data = JSON.parse(routing.body.read)
          new_grpe = @auth_account.add_group(new_data)

          response.status = 201
          response['Location'] = "#{@group_route}/#{new_grpe.group_id}"
          { message: 'Group events saved', data: new_grpe }.to_json
        rescue Sequel::MassAssignmentRestriction
          routing.halt 400, { message: 'Illegal Request' }.to_json
        rescue StandardError => e
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
