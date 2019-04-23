# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Document Handling' do
  include Rack::Test::Methods

  before do 
    wipe_database
  end
    
  it 'HAPPY: should be able to get list of all users' do
    CGroup2::User.create(DATA[:users][0]).save
    CGroup2::User.create(DATA[:users][1]).save

    get "api/v1/users"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single user' do
    user_data = DATA[:users][1]
    CGroup2::User.create(user_data).save
    usr = CGroup2::User.first

    get "/api/v1/users/#{usr.user_id}"
    _(last_response.status).must_equal 200

    result_attribute = JSON.parse(last_response.body)['data']['attributes']

    _(result_attribute['user_id']).must_equal usr.user_id
    _(result_attribute['name']).must_equal user_data['name']
    _(result_attribute['sex']).must_equal user_data['sex']
    _(result_attribute['email']).must_equal user_data['email']
    _(result_attribute['birth']).must_equal user_data['birth']
  end

  it 'SAD: should return error if unknown user requested' do
    get "/api/v1/users/foobar"

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new user' do
    user_data = DATA[:users][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post "/api/v1/users", user_data.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    event = CGroup2::User.first

    _(created['user_id']).must_equal event.user_id
    _(created['name']).must_equal user_data['name']
    _(created['sex']).must_equal user_data['sex']
    _(created['email']).must_equal user_data['email']
    _(created['birth']).must_equal user_data['birth']
  end
end