# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test Document Handling' do
  include Rack::Test::Methods

  before do 
    wipe_database

    DATA[:users].each do |user_data|
        CGroup2::User.create(user_data)
      end
  end

  it 'HAPPY: should be able to get list of all group' do

    get "api/v1/users/#{usr.user_id}/groups"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single group' do
    existing_group = DATA[:groups][1]
    usr = CGroup2::User.first
    event = usr.add_group(event_data).save

    get "/api/v1/users/#{usr.user_id}/groups/#{event.group_id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['group_id']).must_equal event.group_id
    _(result['data']['attributes']['title']).must_equal existing_group['title']
  end

  it 'SAD: should return error if unknown group requested' do
    usr = CGroup2::User.first
    get "/api/v1/users/#{usr.user_id}/groups/foobar"

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new group' do
    existing_group = DATA[:groups][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post "api/v1/users/#{usr.user_id}/groups", existing_group.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    event = CGroup2::Group.first

    _(created['group_id']).must_equal event.group_id
    _(created['title']).must_equal existing_group['title']
    _(created['repo_url']).must_equal existing_group['repo_url']
  end
end