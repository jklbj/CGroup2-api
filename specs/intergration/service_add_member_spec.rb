# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddMember service' do
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

  it 'HAPPY: should be able to add a member to a group' do
    CGroup2::AddMember.call(
      account: @owner,
      group: @group,
      member_email: @member.email
    )

    _(@member.groups.count).must_equal 1
    _(@member.groups.first).must_equal @group
  end

  it 'BAD: should not add owner as a member' do
    proc {
      CGroup2::AddMember.call(
        account: @owner,
        group: @group,
        member_email: @owner.email
      )
    }.must_raise CGroup2::AddMember::ForbiddenError
  end
end
