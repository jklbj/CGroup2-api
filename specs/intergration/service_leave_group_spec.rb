# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test LeaveGroup service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      CGroup2::Account.create(account_data)
    end

    group_data = DATA[:group_events].first

    @owner = CGroup2::Account.all[0]
    @member = CGroup2::Account.all[1]
    @group = CGroup2::CreateGroupForOwner.call(
      owner_id: @owner.account_id, group_data: group_data
    )
  end

  it 'HAPPY: should be able to leave a group' do
    CGroup2::AddMember.call(
      account: @owner, group: @group, member_email: @member.email
    )
    leave = CGroup2::LeaveGroup.call(
      req_username: @member.name,
      member_email: @member.email,
      group_id: @group.group_id     
    )

    _(@member.participations.count).must_equal 0
    _(@member.participations.first).must_equal nil
    _(leave).must_equal @member
  end

  it 'BAD: should not leave a group if you are owner' do
    CGroup2::AddMember.call(
      account: @owner, group: @group, member_email: @member.email
    )
    proc {
      CGroup2::LeaveGroup.call(
        req_username: @owner.name,
        member_email: @owner.email,
        group_id: @group.group_id        
      )
    }.must_raise CGroup2::LeaveGroup::ForbiddenError
  end

  it 'BAD: should not leave a group if you are not in the group' do
    proc {
      CGroup2::LeaveGroup.call(
        req_username: @member.name,
        member_email: @member.email,
        group_id: @group.group_id        
      )
    }.must_raise CGroup2::LeaveGroup::ForbiddenError
  end
end


        

