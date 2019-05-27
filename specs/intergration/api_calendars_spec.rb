# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Calendar Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  describe 'Getting calendar events' do
    describe 'Getting list of calendar events' do
      before do
        @account_data = DATA[:accounts][0]
        account = CGroup2::Account.create(@account_data)
        account.add_calendar(DATA[:calendar_events][0])
        account.add_calendar(DATA[:calendar_events][1])
      end

      it 'HAPPY: should get list for authorized account' do
        auth = CGroup2::AuthenticateAccount.call(
          name: @account_data['name'],
          password: @account_data['password']
        )

        header 'AUTHORIZATION', "Bearer #{auth[:attributes][:auth_token]}"
        get 'api/v1/calendar_events'

        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 2
      end

      it 'BAD: should not process for unauthorized account' do
        header 'AUTHORIZATION', 'Bearer bad_token'
        get 'api/v1/calendar_events'

        _(last_response.status).must_equal 403

        result = JSON.parse last_response.body
        _(result['data']).must_be_nil
      end
    end

    it 'HAPPY: should be able to get details of a single calendar event' do
      existing_cal = DATA[:calendar_events][1]
      CGroup2::Calendar.create(existing_cal)
      id = CGroup2::Calendar.first.calendar_id

      get "/api/v1/calendar_events/#{id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['attribute']['calendar_id']).must_equal id
      _(result['attribute']['title']).must_equal existing_cal['title']
    end

    it 'SAD: should return error if unknown calendar event requested' do
      get '/api/v1/calendar_events/foobar'

      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      CGroup2::Calendar.create(title: 'New Calendar Event')
      CGroup2::Calendar.create(title: 'Newer Calendar Event')
      get 'api/v1/calendar_events/2%20or%20id%3E0'

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Calendar Events' do
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @cal_data = DATA[:calendar_events][1]
    end

    it 'HAPPY: should be able to create new calendar events' do
      post 'api/v1/calendar_events', @cal_data.to_json, @req_header

      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attribute']
      cal = CGroup2::Calendar.first

      _(created['calendar_id']).must_equal cal.calendar_id
      _(created['title']).must_equal @cal_data['title']
      _(created['description']).must_equal @cal_data['description']
    end

    it 'SECURITY: should not create calendar event with mass assignment' do
      bad_data = @cal_data.clone
      bad_data['created_at'] = '1900-01-01'

      post 'api/v1/calendar_events', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
