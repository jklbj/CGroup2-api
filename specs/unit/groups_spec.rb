# # frozen_string_literal: true

# require_relative '../spec_helper'

# describe 'Test group Handling' do
#   include Rack::Test::Methods

#   before do
#     wipe_database

#     DATA[:accounts].each do |account_data|
#       CGroup2::Account.create(account_data)
#     end
#   end

#   it 'HAPPY: should retrieve correct data from database' do
#     event_data = DATA[:groups][1]
#     account = CGroup2::Account.first
#     new_event = Account.add_group(event_data)

#     group_event = CGroup2::Group.find(group_id: new_event.group_id)
#     _(group_event.title).must_equal new_event.title
#     _(group_event.description).must_equal new_event.description
#     _(group_event.event_start_at).must_equal new_event.event_start_at
#     _(group_event.event_end_at).must_equal new_event.event_end_at
#   end

#   it 'SECURITY: should secure sensitive attributes' do
#     event_data = DATA[:groups][1]
#     account = CGroup2::Account.first
#     new_event = Account.add_group(event_data)
#     stored_event = app.DB[:groups].first

#     _(stored_event[:title_secure]).wont_equal new_event.title
#     _(stored_event[:description_secure]).wont_equal new_event.description
#     _(stored_event[:member_id_secure]).wont_equal new_event.member_id
#   end
# end
