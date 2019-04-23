# frozen_string_literal: true

require_relative '../spec_helper'

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
    _(result['calendar_ids'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single calendar event' do
    event_data = DATA[:calendars][1]
    usr = CGroup2::User.first
    event = usr.add_calendar(event_data).save

    get "/api/v1/users/#{usr.user_id}/calendar_events/#{event.calendar_id}"
    _(last_response.status).must_equal 200

    result_attribute = JSON.parse(last_response.body)['data']['attribute']
    
    _(result_attribute['calendar_id']).must_equal event.calendar_id
    _(result_attribute['title']).must_equal event_data['title']
    _(result_attribute['description']).must_equal event_data['description']
    # _(result_attribute['event_start_at']).must_equal event_data['event_start_at']
    # _(result_attribute['event_end_at']).must_equal event_data['event_end_at']
  end

  it 'SAD: should return error if unknown calendar event requested' do
    usr = CGroup2::User.first
    get "/api/v1/users/#{usr.user_id}/calendar_events/foobar"

    _(last_response.status).must_equal 404
  end
  
  describe 'Creating calendar event' do
    before do
      @user = CGroup2::User.first
      @event_data = DATA[:calendars][1]
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should be able to create new calendar event' do
      usr = CGroup2::User.first
      event_data = DATA[:calendars][1]

      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post "api/v1/users/#{usr.user_id}/calendar_events",
          event_data.to_json, req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attribute']
      event = CGroup2::Calendar.first

      _(created['calendar_id']).must_equal event.calendar_id
      _(created['title']).must_equal event_data['title']
      _(created['description']).must_equal event_data['description']
      # _(created['event_start_at']).must_equal event_data['event_start_at']
      # _(created['event_end_at']).must_equal event_data['event_end_at']
    end

    it 'SECURITY: should not create calendar events with mass assignment' do
      bad_data = @event_data.clone
      bad_data['created_at'] = '1999-01-01'
      bad_data['updated_at'] = '2019-01-01'
      post "api/v1/users/#{@user.user_id}/calendar_events",
           bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end