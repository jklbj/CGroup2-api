# frozen_string_literal: true

Sequel.seed(:development) do
    def run
      puts 'Seeding accounts, calendars, groups'
      create_accounts
      create_owned_calendars
      create_owned_groups
    end
  end
  
  require 'yaml'
  DIR = File.dirname(__FILE__)
  ACCOUNTS_INFO = YAML.load_file("#{DIR}/account_seeds.yml")
  CALENDAR_INFO = YAML.load_file("#{DIR}/calendar_seeds.yml")
  GROUP_INFO = YAML.load_file("#{DIR}/group_seeds.yml")
  OWNER_CAL_INFO = YAML.load_file("#{DIR}/owners_calendars.yml")
  OWNER_GROUP_INFO = YAML.load_file("#{DIR}/owners_groups.yml")
  
  def create_accounts
    ACCOUNTS_INFO.each do |account_info|
      CGroup2::Account.create(account_info)
    end
  end
  
  def create_owned_calendars
    OWNER_CAL_INFO.each do |owner_cal|
      account = CGroup2::Account.first(name: owner_cal['username'])
      owner_cal['cal_name'].each do |cal_name|
        cal_data = CALENDAR_INFO.find { |cal| cal['title'] == cal_name }
        CGroup2::CreateCalendarForOwner.call(
          owner_id: account.account_id, calendar_data: cal_data
        )
      end
    end
  end
  
  def create_owned_groups
    OWNER_GROUP_INFO.each do |owner_group|
      account = CGroup2::Account.first(name: owner_group['username'])
      owner_group['group_name'].each do |group_name|
        group_data = GROUP_INFO.find { |group| group['title'] == group_name }
        CGroup2::CreateGroupForOwner.call(
          owner_id: account.account_id, group_data: group_data
        )
      end
    end
  end

  