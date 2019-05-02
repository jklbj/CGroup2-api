# # frozen_string_literal: true

# require_relative '../spec_helper'

# describe 'Test Document Handling' do
#   include Rack::Test::Methods

#   before do 
#     wipe_database

#     DATA[:accounts].each do |account_data|
#       CGroup2::Account.create(account_data)
#     end
#   end

#   it 'HAPPY: should be able to get list of all group' do
#     usr = CGroup2::Account.first
#     DATA[:groups].each do |group|
#       usr.add_group(group)
#     end

#     get "api/v1/accounts/#{usr.account_id}/group_events"
#     _(last_response.status).must_equal 200
    
    
#     result = JSON.parse last_response.body
#     _(result['group_ids'].count).must_equal 2
#   end

#   it 'HAPPY: should be able to get details of a single group' do
#     existing_group = DATA[:groups][1]
#     usr = CGroup2::Account.first
#     event = usr.add_group(existing_group).save

#     get "/api/v1/accounts/#{usr.account_id}/group_events/#{event.group_id}"
#     _(last_response.status).must_equal 200

#     result_attribute = JSON.parse(last_response.body)['data']['attribute']

#     _(result_attribute['group_id']).must_equal event.group_id
#     _(result_attribute['title']).must_equal existing_group['title']
#     _(result_attribute['description']).must_equal existing_group['description']
#     _(result_attribute['limit_number']).must_equal existing_group['limit_number']
#     _(result_attribute['member_id']).must_equal existing_group['member_id']
#   end

#   it 'SAD: should return error if unknown group requested' do
#     usr = CGroup2::Account.first
#     get "/api/v1/accounts/#{usr.account_id}/group_events/foobar"

#     _(last_response.status).must_equal 404
#   end

#   describe 'Creating group event' do
#     before do
#       @account = CGroup2::Account.first
#       @event_data = DATA[:groups][1]
#       @req_header = { 'CONTENT_TYPE' => 'application/json' }
#     end

#     it 'HAPPY: should be able to create new group' do
#       usr = CGroup2::Account.first
#       existing_group = DATA[:groups][1]

#       req_header = { 'CONTENT_TYPE' => 'application/json' }
      
#       post "/api/v1/accounts/#{usr.account_id}/group_events", existing_group.to_json, req_header
#       _(last_response.status).must_equal 201
#       _(last_response.header['Location'].size).must_be :>, 0

#       created = JSON.parse(last_response.body)['data']['data']['attribute']
#       event = CGroup2::Group.first

#       _(created['group_id']).must_equal event.group_id
#       _(created['title']).must_equal existing_group['title']
#       _(created['description']).must_equal existing_group['description']
#       _(created['limit_number']).must_equal existing_group['limit_number']
#       _(created['member_id']).must_equal existing_group['member_id']
#     end

#     it 'SECURITY: should not create group events with mass assignment' do
#       bad_data = @event_data.clone
#       bad_data['created_at'] = '1999-01-01'
#       bad_data['updated_at'] = '2019-01-01'
#       post "api/v1/accounts/#{@account.account_id}/group_events",
#            bad_data.to_json, @req_header

#       _(last_response.status).must_equal 400
#       _(last_response.header['Location']).must_be_nil
#     end
#   end
# end