# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Group Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = CGroup2::Account.create(@account_data)
    @wrong_account = CGroup2::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting group events' do
    describe 'Getting list of group events' do
      before do
        @account.add_group(DATA[:group_events][0])
        @account.add_group(DATA[:group_events][1])
      end

      it 'HAPPY: should get list for authorized account' do
        header 'AUTHORIZATION', auth_header(@account_data)
        get 'api/v1/group_events/all'

        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 2
      end

      it 'BAD: should not process for unauthorized account' do
        get 'api/v1/group_events/all'
        _(last_response.status).must_equal 403

        result = JSON.parse last_response.body
        _(result['data']).must_be_nil
      end
    end

    it 'HAPPY: should be able to get details of a single group event' do
      grp = @account.add_group(DATA[:group_events][0])

      header 'AUTHORIZATION', auth_header(@account_data)

      get "/api/v1/group_events/#{grp.group_id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body

      result = JSON.parse(last_response.body)['data']
      _(result['attribute']['group_id']).must_equal grp.group_id
      _(result['attribute']['title']).must_equal grp.title
    end

    it 'HAPPY: should see all your own groups' do
      grp = @account.add_group(DATA[:group_events][0])
      @account.add_group(DATA[:group_events][1])

      header 'AUTHORIZATION', auth_header(@account_data)
      get "/api/v1/group_events"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data'][0]
      _(result['attribute']['group_id']).must_equal grp.group_id
      _(result['attribute']['title']).must_equal grp.title
    end

    it 'SAD: should return error if unknown group event requested' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get '/api/v1/group_events/foobar'

      _(last_response.status).must_equal 404
    end

    it 'BAD SQL_INJECTION: should prevent basic SQL injection of id' do
      @account.add_group(DATA[:group_events][0])
      @account.add_group(DATA[:group_events][1])

      header 'AUTHORIZATION', auth_header(@account_data)
      get 'api/v1/group_events/2%20or%20id%3E0'

      # deliberately not reporting detection -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Group Events' do
    before do
      @grp_data = DATA[:group_events][1]
    end

    it 'HAPPY: should be able to create new group events' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/group_events', @grp_data.to_json

      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attribute']

      grp = CGroup2::Group.first

      _(created['group_id']).must_equal grp.group_id
      _(created['title']).must_equal @grp_data['title']
      _(created['limit_number']).must_equal @grp_data['limit_number']
    end

    it 'SAD AUTHORIZATION: should not create group event without authorization' do
      post 'api/v1/group_events', @grp_data.to_json

      created = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(created).must_be_nil
    end
    
    it 'BAD MASS_ASSIGNMENT: should not create group event with mass assignment' do
      bad_data = @grp_data.clone
      bad_data['created_at'] = '1900-01-01'

      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/group_events', bad_data.to_json

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end

  describe 'Delete a Group Event' do
    before do
      @grp_data = DATA[:group_events][1]
      @grp = @account.add_group(@grp_data)
    end

    it 'HAPPY: should delete a group event' do
      header 'AUTHORIZATION', auth_header(@account_data)
      delete "api/v1/group_events/#{@grp.group_id}"

      deleted = JSON.parse(last_response.body)
      deleted['message'].must_include 'deleted'
    end

    it 'SAD: should not delete a group event' do
      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      delete "api/v1/group_events/#{@grp.group_id}"

      _(last_response.status).must_equal 403
    end
  end

  describe 'Add a group member' do
    before do
      @grp_data = DATA[:group_events][1]
      @grp = @account.add_group(@grp_data)
    end

    it 'HAPPY: should be added a member to a group' do
      header 'AUTHORIZATION', auth_header(@account_data)
      put "api/v1/group_events/#{@grp.group_id}/members",
      { email: @wrong_account.email }.to_json

      member = JSON.parse(last_response.body)['data']['attributes']
      
      member['name'].must_equal 'KevinYang'
      member['email'].must_equal 'KevinYang@gmail.com'
    end

    it 'SAD: should not be added a member to a group' do
      @grp.add_member(@wrong_account)

      header 'AUTHORIZATION', auth_header(@account_data)
      put "api/v1/group_events/#{@grp.group_id}/members",
      { email: @wrong_account.email }.to_json

      _(last_response.status).must_equal 403
    end
  end

  describe 'Remove a member from a group' do
    before do
      @grp_data = DATA[:group_events][1]
      @grp = @account.add_group(@grp_data)
    end

    it 'HAPPY: should be romoved a member from a group' do
      @grp.add_member(@wrong_account)

      header 'AUTHORIZATION', auth_header(@account_data)
      delete "api/v1/group_events/#{@grp.group_id}/members",
      { action: 'remove', email: @wrong_account.email }.to_json

      member = JSON.parse(last_response.body)['data']['attributes']
      puts "member: #{member}"
      
      member['name'].must_equal 'KevinYang'
      member['email'].must_equal 'KevinYang@gmail.com'
    end

    it 'SAD: should not be added a member to a group' do

      header 'AUTHORIZATION', auth_header(@account_data)
      delete "api/v1/group_events/#{@grp.group_id}/members",
      { action: 'remove', email: @wrong_account.email }.to_json

      _(last_response.status).must_equal 403
    end
  end
end
