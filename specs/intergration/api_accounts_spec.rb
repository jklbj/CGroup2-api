# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Account Handling' do
  include Rack::Test::Methods

  before do 
    wipe_database
  end
  
  describe 'Account information' do
    it 'HAPPY: should be able to get list of all users' do
      CGroup2::Account.create(DATA[:accounts][0]).save
      CGroup2::Account.create(DATA[:accounts][1]).save

      get "api/v1/accounts"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single user' do
      account_data = DATA[:acounts][1]
      CGroup2::Account.create(account_data).save
      account = CGroup2::Account.first

      get "/api/v1/accounts/#{account.account_id}"
      _(last_response.status).must_equal 200

      result_attribute = JSON.parse(last_response.body)['data']['attributes']

      _(result_attribute['account_id']).must_equal account.account_id
      _(result_attribute['name']).must_equal account.name
      _(result_attribute['sex']).must_equal account.sex
      _(result_attribute['email']).must_equal account.email
      _(result_attribute['birth']).must_equal account.birth
      _(result_attribute['salt']).must_be_nil
      _(result_attribute['password']).must_be_nil
      _(result_attribute['password_hash']).must_be_nil
    end

    it 'SAD: should return error if unknown account requested' do
      get "/api/v1/accounts/foobar"

      _(last_response.status).must_equal 404
    end
  end

  describe 'Account Creation' do
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @account_data = DATA[:accounts][1]
    end

    it 'HAPPY: should be able to create new user' do
      post "/api/v1/accounts", @account_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']
      account = CGroup2::Account.first

      _(created['account_id']).must_equal account.id
      _(created['name']).must_equal @account_data['name']
      _(created['email']).must_equal @account_data['email']
      _(account.password?(@account_data['password'])).must_equal true
      _(account.password?('not_really_the_password')).must_equal false
    end

    it 'BAD: should not create account with illegal attributes' do
      bad_data = @account_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/accounts', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end