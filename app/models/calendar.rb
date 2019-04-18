require 'json'
require 'base64'
require 'rbnacl'

module CGroup2
    class Calendar
        STORE_DIR = 'app/db/store/'

        def initialize(new_document)
            @calendar_id = new_document['calendar_id'] || new_id
            @title = new_document['title']
            @leader_id = new_document['leader_id']
            @description = new_document['description']
            @limit_member = new_document['limit_member']
            @group_founded_date = new_document['group_founded_date']
            @group_founded_time = new_document['group_founded_time']
            @due_date = new_document['due_date']
            @due_time = new_document['due_time']
            @member_id = new_document['member_id']
            @event_start_date = new_document['event_start_date']
            @event_start_time = new_document['event_start_time']
            @event_end_date = new_document['event_end_date']
            @event_end_time = new_document['event_end_time']
            
        end

        attr_reader :Calendar_id, :title, :leader_id, :leader_name, :description, :limit_member, :group_founded_date, :group_founded_time, :due_date, :due_time, :member_id, :event_start_date, :event_start_time, :event_end_date, :event_end_time

        def to_json(options = {})
            JSON(
                {
                    type: 'calendar_event',
                    calendar_id, : calendar_id,
                    title: title,
                    leader_id: leader_id,
                    leader_name: leader_name,
                    description: description,
                    limit_member: limit_member,
                    group_founded_date: group_founded_date,
                    group_founded_time: group_founded_time,
                    due_date: due_date,
                    due_time: due_time,
                    member_id: member_id,
                    event_start_date: event_start_date,
                    event_start_time: event_start_time,
                    event_end_date: event_end_date,
                    event_end_time: event_end_time
                },
                options
            )
        end

        # File store must be setup once when application runs
        def self.setup
            Dir.mkdir(STORE_DIR) unless Dir.exist? STORE_DIR
        end

        # Stores document in file store
        def save
            File.write(STORE_DIR + id + '.txt', to_json)
        end

        # Query method to find one document
        def self.find(find_id)
            calendar_file = File.read(STORE_DIR + find_id + '.txt')
            Transaction.new JSON.parse(calendar_file)
        end

        def self.all
            Dir.glob(STORE_DIR + '*.txt').map do |file|
                file.match(/#{Regexp.quote(STORE_DIR)}(.*)\.txt/)[1]
            end
        end

        private

        def new_id
            timestamp = Time.now.to_f.to_json
            Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
        end
    end
end
            