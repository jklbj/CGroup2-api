# frozen_string_literal: true

require 'http'
require 'google/apis/calendar_v3'
require 'googleauth'
require 'google/api_client/client_secrets'
require 'googleauth/stores/file_token_store'
require 'date'
require 'fileutils'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
APPLICATION_NAME = 'Google Calendar API Ruby CGroup2'.freeze
CREDENTIALS_PATH = 'credentials.json'.freeze

TOKEN_PATH = 'config/token.yaml'.freeze
SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY

module CGroup2
  # Find or create google calendar by google code
  class AuthorizeSso
    def initialize(account, config)
      @auth_account = account
      @config = config
    end

    def call(access_token)
      response_data = get_google_calendar(access_token)
      find_or_create_calendar_events(response_data)
    end

    def get_google_calendar(access_token)
      # Initialize the Google API
      client = Signet::OAuth2::Client.new(access_token: access_token)

      service = Google::Apis::CalendarV3::CalendarService.new

      service.authorization = client

      calendar_id = 'primary'

      response = service.list_events(calendar_id,
                                  max_results: 10,
                                  single_events: true,
                                  order_by: 'startTime',
                                  time_min: DateTime.now.rfc3339)
      puts 'Upcoming events:'
      puts 'No upcoming events found' if response.items.empty?
      response.items.map do |event|
        start = event.start.date_time.to_s
        end_d = event.end.date_time.to_s
        puts "- #{event.summary} (#{start})"
        to_h(event.summary,event.description,start,end_d)
      end
    end

    def find_or_create_calendar_events(calendar_events)
      database_calendar_events = @auth_account.calendars
      calendar_events.each do |event|
        repeat = false
        start = event.event_start_at
        end_d = event.event_end_at
        database_calendar_events.each do |database_event|
          repeat = true if (start == database_event.event_start_at && end_d == database_event.event_end_at) 
        end
        @auth_account.add_calendar(event) unless repeat
      end
    end

    def to_h(title, description, start, end_d)
      {
        title: title,
        description: description,
        event_start_at: start,
        event_end_at: end_d
      }
    end
  end
end
