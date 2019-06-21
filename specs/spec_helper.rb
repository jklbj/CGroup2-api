# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  CGroup2::Account.map(&:destroy)
  CGroup2::Group.map(&:destroy)
  CGroup2::Calendar.map(&:destroy)
end

def authenticate(account_data)
  CGroup2::AuthenticateAccount.call(
    name: account_data['name'],
    password: account_data['password']
  )
end

def auth_header(account_data)
  auth = authenticate(account_data)
  "Bearer #{auth[:attributes][:auth_token]}"
end

def authorization(account_data)
  auth = authenticate(account_data)

  contents = AuthToken.contents(auth[:attributes][:auth_token])
  account = contents['payload']['attributes']
  { account: Credence::Account.first(username: account['username']),
    scope:   AuthScope.new(contents['scope']) }
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:accounts] = YAML.safe_load File.read('app/db/seeds/account_seeds.yml')
DATA[:calendar_events] = YAML.safe_load File.read('app/db/seeds/calendar_seeds.yml')
DATA[:group_events] = YAML.safe_load File.read('app/db/seeds/group_seeds.yml')
