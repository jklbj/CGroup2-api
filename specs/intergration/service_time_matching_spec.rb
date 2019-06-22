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

    result = CGroup2::TimeMatching.call(group)
    (CGroup2::TimeMatching.date_format_transform(result[0][0])).must_equal '2019-04-20T12:13:40'
    
    (result[0][1]).must_equal 0
    (result[1][1]).must_equal 1
    (result[2][1]).must_equal 0
  end

  it 'HAPPY: time start at the same time' do
    @account1.add_calendar(@calendar_event_data[4])
    @account2.add_calendar(@calendar_event_data[2])
    @account2.add_calendar(@calendar_event_data[6])
    group = CGroup2::CreateGroupForOwner.call(
      owner_id: @account1.account_id, group_data: @group_event_data[0]
    )
    CGroup2::AddMember.call(
        account: @account1, group: group, member_email: @account2.email
    )

    result = CGroup2::TimeMatching.call(group)
    (CGroup2::TimeMatching.date_format_transform(result[0][0])).must_equal '2019-04-20T12:13:40'
    (result[0][1]).must_equal 0
  end

  it 'HAPPY: group time is lastest' do
    group = CGroup2::CreateGroupForOwner.call(
      owner_id: @account1.account_id, group_data: @group_event_data[2]
    )
    CGroup2::AddMember.call(
        account: @account1, group: group, member_email: @account2.email
    )

    result = CGroup2::TimeMatching.call(group)

    (CGroup2::TimeMatching.date_format_transform(result[0][0])).must_equal '2019-04-25T12:13:40'
    (CGroup2::TimeMatching.date_format_transform(result[1][0])).must_equal '2019-05-21T10:00:00'
    (CGroup2::TimeMatching.date_format_transform(result[2][0])).must_equal '2019-05-22T10:00:00'
    (CGroup2::TimeMatching.date_format_transform(result[3][0])).must_equal '2019-05-25T10:00:00'
    (CGroup2::TimeMatching.date_format_transform(result[4][0])).must_equal '2019-05-26T10:00:00'

    (result[0][1]).must_equal 0
    (result[1][1]).must_equal 1
    (result[2][1]).must_equal 0
    (result[3][1]).must_equal 1
    (result[4][1]).must_equal 0
  end

  it 'HAPPY: member event start time is earliest' do
    @account2.add_calendar(@calendar_event_data[9])
    
    group = CGroup2::CreateGroupForOwner.call(
      owner_id: @account1.account_id, group_data: @group_event_data[0]
    )
    CGroup2::AddMember.call(
        account: @account1, group: group, member_email: @account2.email
    )

    result = CGroup2::TimeMatching.call(group)

    (CGroup2::TimeMatching.date_format_transform(result[0][0])).must_equal '2019-04-20T12:13:40'
    (CGroup2::TimeMatching.date_format_transform(result[1][0])).must_equal '2019-04-30T10:00:00'
    
    (result[0][1]).must_equal 2
    (result[1][1]).must_equal 0
  end

  it 'HAPPY: member event end time is lastest' do
    @account2.add_calendar(@calendar_event_data[8])
    group = CGroup2::CreateGroupForOwner.call(
      owner_id: @account1.account_id, group_data: @group_event_data[0]
    )
    CGroup2::AddMember.call(
        account: @account1, group: group, member_email: @account2.email
    )

    result = CGroup2::TimeMatching.call(group)

    (CGroup2::TimeMatching.date_format_transform(result[0][0])).must_equal '2019-04-20T12:13:40'
    
    (result[0][1]).must_equal 1
  end

  it 'HAPPY: group event start time is between an event start and end' do    
    @account2.add_calendar(@calendar_event_data[9])
    group = CGroup2::CreateGroupForOwner.call(
      owner_id: @account2.account_id, group_data: @group_event_data[0]
    )

    result = CGroup2::TimeMatching.call(group)

    (CGroup2::TimeMatching.date_format_transform(result[0][0])).must_equal '2019-04-20T12:13:40'
    
    (result[0][1]).must_equal 2
    (result[1][1]).must_equal 0
  end
end