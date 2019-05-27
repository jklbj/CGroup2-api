# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Group Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  describe 'Getting group events' do
    describe 'Getting list of group events' do
      before do
        @account_data = DATA[:accounts][0]
        account = CGroup2::Account.create(@account_data)
        account.add_group(DATA[:group_events][0])
        account.add_group(DATA[:group_events][1])
      end

      it 'HAPPY: should get list for authorized account' do
        auth = CGroup2::AuthenticateAccount.call(
          name: @account_data['name'],
          password: @account_data['password']
        )

        header 'AUTHORIZATION', "Bearer #{auth[:attributes][:auth_token]}"
        get 'api/v1/group_events'
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 2
      end

      it 'BAD: should not process for unauthorized account' do
        header 'AUTHORIZATION', 'Bearer bad_token'
        get 'api/v1/group_events'
        _(last_response.status).must_equal 403

        result = JSON.parse last_response.body
        _(result['data']).must_be_nil
      end
    end

    it 'HAPPY: should be able to get details of a single group event' do
      existing_grp = DATA[:group_events][1]
      CGroup2::Group.create(existing_grp)
      id = CGroup2::Group.first.group_id

      get "/api/v1/group_events/#{id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body

      _(result['attribute']['group_id']).must_equal id
      _(result['attribute']['title']).must_equal existing_grp['title']
    end

    it 'SAD: should return error if unknown group event requested' do
      get '/api/v1/group_events/foobar'

      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      CGroup2::Group.create(title: 'New Group Event', limit_number: 5)
      CGroup2::Group.create(title: 'Newer Group Event', limit_number: 5)
      get 'api/v1/group_events/2%20or%20id%3E0'

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Group Events' do
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @grp_data = DATA[:group_events][1]
    end

    it 'HAPPY: should be able to create new group events' do
      post 'api/v1/group_events', @grp_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attribute']

      grp = CGroup2::Group.first

      _(created['group_id']).must_equal grp.group_id
      _(created['title']).must_equal @grp_data['title']
      _(created['limit_number']).must_equal @grp_data['limit_number']
    end

    it 'SECURITY: should not create group event with mass assignment' do
      bad_data = @grp_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/group_events', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
