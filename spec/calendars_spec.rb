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
    
  it 'HAPPY: should be able to get list of all calendar events' do
    usr = CGroup2::User.first
    DATA[:calendars].each do |event|
      usr.add_calendar(event)
    end

    get "api/v1/users/#{usr.user_id}/calendar_events"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single calendar event' do
    event_data = DATA[:calendars][1]
    usr = CGroup2::User.first
    event = usr.add_calendar(event_data).save

    get "/api/v1/users/#{usr.user_id}/calendar_events/#{event.calendar_id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['calendar_id']).must_equal cal.calendar_id
    _(result['data']['attributes']['title']).must_equal event_data['title']
    _(result['data']['attributes']['leader_id']).must_equal event_data['leader_id']
    _(result['data']['attributes']['limit_member']).must_equal event_data['limit_member']
    _(result['data']['attributes']['member_id']).must_equal event_data['member_id']
  end

  it 'SAD: should return error if unknown calendar event requested' do
    usr = CGroup2::User.first
    get "/api/v1/users/#{usr.user_id}/calendar_events/foobar"

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new calendar event' do
    usr = CGroup2::User.first
    event_data = DATA[:calendars][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post "api/v1/users/#{usr.user_id}/calendar_events",
         event_data.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    event = CGroup2::Calendar.first

    _(created['calendar_id']).must_equal event.calendar_id
    _(created['title']).must_equal event_data['title']
    _(created['leader_id']).must_equal event_data['leader_id']
    _(created['limit_member']).must_equal event_data['limit_member']
    _(created['member_id']).must_equal event_data['member_id']
  end
end