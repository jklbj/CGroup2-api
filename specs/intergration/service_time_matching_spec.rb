# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test TimeMatching service' do
  before do
    wipe_database

    @account_data = DATA[:accounts]
    @group_event_data = DATA[:group_events]
    @calendar_event_data = DATA[:calendar_events]

    @account1 = CGroup2::Account.create(@account_data[0])
    @account2 = CGroup2::Account.create(@account_data[1])
    @account1.add_calendar(@calendar_event_data[0]) 
    @account2.add_calendar(@calendar_event_data[5]) 
  end

  it 'HAPPY: should retrieve correct data from database' do
    @account1.add_calendar(@calendar_event_data[1])
    @account1.add_calendar(@calendar_event_data[2])
    @account1.add_calendar(@calendar_event_data[3])
    
    group = CGroup2::CreateGroupForOwner.call(
      owner_id: @account1.account_id, group_data: @group_event_data[0]
    )
    CGroup2::AddMember.call(
        account: @account1, group: group, member_email: @account2.email
    )
    
    CGroup2::TimeMatching.call(group)
  end

  it 'HAPPY: time start at the same time' do
    @account1.add_calendar(@calendar_event_data[1])
    @account1.add_calendar(@calendar_event_data[4])
    @account2.add_calendar(@calendar_event_data[2])
    @account2.add_calendar(@calendar_event_data[6])
    group = CGroup2::CreateGroupForOwner.call(
      owner_id: @account1.account_id, group_data: @group_event_data[0]
    )
    CGroup2::AddMember.call(
        account: @account1, group: group, member_email: @account2.email
    )

    CGroup2::TimeMatching.call(group)
  end

  it 'HAPPY: group time is lastest' do
    group = CGroup2::CreateGroupForOwner.call(
      owner_id: @account1.account_id, group_data: @group_event_data[2]
    )
    CGroup2::AddMember.call(
        account: @account1, group: group, member_email: @account2.email
    )

    CGroup2::TimeMatching.call(group)
  end

  it 'HAPPY: member event start time is earliest' do
    @account2.add_calendar(@calendar_event_data[9])
    
    group = CGroup2::CreateGroupForOwner.call(
      owner_id: @account1.account_id, group_data: @group_event_data[0]
    )
    CGroup2::AddMember.call(
        account: @account1, group: group, member_email: @account2.email
    )

    CGroup2::TimeMatching.call(group)
  end

  it 'HAPPY: member event end time is lastest' do
    @account2.add_calendar(@calendar_event_data[8])
    group = CGroup2::CreateGroupForOwner.call(
      owner_id: @account1.account_id, group_data: @group_event_data[0]
    )
    CGroup2::AddMember.call(
        account: @account1, group: group, member_email: @account2.email
    )

    CGroup2::TimeMatching.call(group)
  end

  it 'HAPPY: group event start time is between an event start and end' do    
    @account2.add_calendar(@calendar_event_data[9])
    group = CGroup2::CreateGroupForOwner.call(
      owner_id: @account2.account_id, group_data: @group_event_data[0]
    )

    CGroup2::TimeMatching.call(group)
  end
end