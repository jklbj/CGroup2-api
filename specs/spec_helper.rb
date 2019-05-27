# frozen_string_literal: true

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

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:accounts] = YAML.safe_load File.read('app/db/seeds/account_seeds.yml')
DATA[:calendar_events] = YAML.safe_load File.read('app/db/seeds/calendar_seeds.yml')
DATA[:group_events] = YAML.safe_load File.read('app/db/seeds/group_seeds.yml')
