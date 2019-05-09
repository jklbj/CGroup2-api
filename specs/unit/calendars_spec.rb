# # frozen_string_literal: true

# require_relative '../spec_helper'

# describe 'Test Calendar Handling' do
#   include Rack::Test::Methods

#   before do
#     wipe_database

#     DATA[:accounts].each do |account_data|
#       CGroup2::Account.create(account_data)
#     end
#   end

#   it 'HAPPY: should retrieve correct data from database' do
#     event_data = DATA[:calendars][1]
#     account = CGroup2::Account.first
#     new_event = Account.add_calendar(event_data)

#     calendar_event = CGroup2::Calendar.find(calendar_id: new_event.calendar_id)
#     _(calendar_event.title).must_equal new_event.title
#     _(calendar_event.description).must_equal new_event.description
#     _(calendar_event.event_start_at).must_equal new_event.event_start_at
#     _(calendar_event.event_end_at).must_equal new_event.event_end_at
#   end

#   it 'SECURITY: should secure sensitive attributes' do
#     event_data = DATA[:calendars][1]
#     account = CGroup2::Account.first
#     new_event = Account.add_calendar(event_data)
#     stored_event = app.DB[:calendars].first

#     _(stored_event[:title_secure]).wont_equal new_event.title
#     _(stored_event[:description_secure]).wont_equal new_event.description
#   end
# end
