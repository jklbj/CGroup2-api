# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Authentication Routes' do
  include Rack::Test::Methods

  before do
    @req_header = { 'CONTENT_TYPE' => 'application/json' }
    wipe_database
  end

  describe 'Account Authentication' do
    before do
      @account_data = DATA[:accounts][1]
      @account = CGroup2::Account.create(@account_data)
    end

    it 'HAPPY: should authenticate valid credentials' do
      credentials = { name: @account_data['name'],
                      password: @account_data['password'] }
      post 'api/v1/auth/authenticate', credentials.to_json, @req_header

      auth_account = JSON.parse(last_response.body)['attributes']['account']['attributes']
      _(last_response.status).must_equal 200
      _(auth_account['name'].must_equal(@account_data['name']))
      _(auth_account['email'].must_equal(@account_data['email']))
      _(auth_account['id'].must_be_nil)
    end

    it 'BAD: should not authenticate invalid password' do
      credentials = { name: @account_data['name'],
                      password: 'fakepassword' }
      
      assert_output(/invalid/i, '') do
        post 'api/v1/auth/authenticate', credentials.to_json, @req_header
      end

      result = JSON.parse(last_response.body)

      _(last_response.status).must_equal 403
      _(result['message']).wont_be_nil
      _(result['attribute']).must_be_nil
    end
  end
end
