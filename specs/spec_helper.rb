# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database  
  app.DB[:calendars].delete
  app.DB[:groups].delete
  app.DB[:accounts].delete
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:accounts] = YAML.safe_load File.read('app/db/seeds/account_seeds.yml')
DATA[:calendars] = YAML.safe_load File.read('app/db/seeds/calendar_seeds.yml')
DATA[:groups] = YAML.safe_load File.read('app/db/seeds/group_seeds.yml')
