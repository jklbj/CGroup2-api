# frozen_string_literal: true

module CGroup2
  # Service object to create new group for a project
  class TimeMatching
    def initialize(all_events)
      @all_events = all_events
    end

    def self.call(group)
      ta = []
      has = Hash.new

      total_cal = []

      total_cal = group.account.calendars
      total_cal.each do |cal|
        if ta.length == 0
          ta.append(cal.event_start_at)
          ta.append(cal.event_end_at)
          has = {cal.event_start_at => 1, cal.event_end_at => 0}
        else
          cal_count = 0
          finish = 0
          event_start_pos = -1
          event_end_pos = -1

          until finish == 1 do
            if cal_count < ta.length - 1
              #Insert into two events (-1 means first is earlier)
              if ((ta[cal_count] <=> cal.event_start_at) == -1) && ((ta[cal_count + 1] <=> cal.event_start_at) == 1)
                ta.insert(cal_count + 1, cal.event_start_at)
                has[cal.event_start_at] = has[ta[cal_count]] + 1
                finish = 1
              #If the start event is the earliest 
              elsif ((ta[cal_count] <=> cal.event_start_at) == 1) && (cal_count == 0)
                ta.insert(cal_count, cal.event_start_at)
                has[cal.event_start_at] = 1
                finish = 1
              #If there are two  events starting at the same time
              elsif (ta[cal_count] <=> cal.event_start_at) == 0
                has[cal.event_start_at] = has[cal.event_start_at] + 1
                finish = 1
              end
              #If the start event is the lastest
            elsif ((ta[cal_count] <=> cal.event_start_at) == -1) && (cal_count == ta.length - 1)
              ta.insert(-1, cal.event_start_at)
              has[cal.event_start_at] = 1
              finish = 1
            end
            cal_count += 1
          end

          cal_count = 0
          finish = 0

          until finish == 1 || cal_count == 10 do
            if cal_count < ta.length - 1
              #Insert into two events (-1 means first is earlier)
              if ((ta[cal_count] <=> cal.event_end_at) == -1) && ((ta[cal_count + 1] <=> cal.event_end_at) == 1)
                ta.insert(cal_count + 1, cal.event_end_at)
                
                i = ta.index(cal.event_start_at) + 1

                until i == cal_count + 1 do
                  has[ta[i]] = has[ta[i]] + 1
                  i += 1
                end

                has[cal.event_end_at] = has[ta[cal_count]] - 1
                finish = 1

              #If there are two  events ending at the same time
              elsif (ta[cal_count] <=> cal.event_end_at) == 0
                has[cal.event_end_at] = has[cal.event_end_at] + 1
                i = ta.index(cal.event_start_at) + 1
                has[cal.event_end_at] = has[ta[cal_count - 1]] - 1

                until i == cal_count do
                  has[ta[i]] = has[ta[i]] + 1
                  i += 1
                end
                finish = 1
              #If the end event is the earliest 
              elsif ((ta[cal_count] <=> cal.event_end_at) == 1) && (cal_count == 0)
                puts "error"
              end
              #If the end event is the lastest
            elsif ((ta[cal_count] <=> cal.event_end_at) == -1) && (cal_count == ta.length - 1)
              ta.insert(-1, cal.event_end_at)

              i = ta.index(cal.event_start_at) + 1

              until i == cal_count + 1 do
                has[ta[i]] = has[ta[i]] + 1
                i += 1
              end

              has[cal.event_end_at] = 0
              finish = 1
            end
            cal_count += 1
          end
        end
      end

      group.members.each do |member|
        total_cal = member.calendars
        total_cal.each do |cal|
          if ta.length == 0
            ta.append(cal.event_start_at)
            ta.append(cal.event_end_at)
            has = {cal.event_start_at => 1, cal.event_end_at => 0}
          else
            cal_count = 0
            finish = 0
            event_start_pos = -1
            event_end_pos = -1

            until finish == 1 do
              if cal_count < ta.length - 1
                #Insert into two events (-1 means first is earlier)
                if ((ta[cal_count] <=> cal.event_start_at) == -1) && ((ta[cal_count + 1] <=> cal.event_start_at) == 1)
                  ta.insert(cal_count + 1, cal.event_start_at)
                  has[cal.event_start_at] = has[ta[cal_count]] + 1
                  finish = 1
                #If the start event is the earliest 
                elsif ((ta[cal_count] <=> cal.event_start_at) == 1) && (cal_count == 0)
                  ta.insert(cal_count, cal.event_start_at)
                  has[cal.event_start_at] = 1
                  finish = 1
                #If there are two  events starting at the same time
                elsif (ta[cal_count] <=> cal.event_start_at) == 0
                  has[cal.event_start_at] = has[cal.event_start_at] + 1
                  finish = 1
                end
                #If the start event is the lastest
              elsif ((ta[cal_count] <=> cal.event_start_at) == -1) && (cal_count == ta.length - 1)
                ta.insert(-1, cal.event_start_at)
                has[cal.event_start_at] = 1
                finish = 1
              end
              cal_count += 1
            end

            cal_count = 0
            finish = 0

            until finish == 1 || cal_count == 10 do
              if cal_count < ta.length - 1
                #Insert into two events (-1 means first is earlier)
                if ((ta[cal_count] <=> cal.event_end_at) == -1) && ((ta[cal_count + 1] <=> cal.event_end_at) == 1)
                  ta.insert(cal_count + 1, cal.event_end_at)
                  
                  i = ta.index(cal.event_start_at) + 1

                  until i == cal_count + 1 do
                    has[ta[i]] = has[ta[i]] + 1
                    i += 1
                  end

                  has[cal.event_end_at] = has[ta[cal_count]] - 1
                  finish = 1

                #If there are two  events ending at the same time
                elsif (ta[cal_count] <=> cal.event_end_at) == 0
                  has[cal.event_end_at] = has[cal.event_end_at] + 1
                  i = ta.index(cal.event_start_at) + 1
                  has[cal.event_end_at] = has[ta[cal_count - 1]] - 1

                  until i == cal_count do
                    has[ta[i]] = has[ta[i]] + 1
                    i += 1
                  end
                  finish = 1
                #If the end event is the earliest 
                elsif ((ta[cal_count] <=> cal.event_end_at) == 1) && (cal_count == 0)
                  puts "error"
                end
                #If the end event is the lastest
              elsif ((ta[cal_count] <=> cal.event_end_at) == -1) && (cal_count == ta.length - 1)
                ta.insert(-1, cal.event_end_at)

                i = ta.index(cal.event_start_at) + 1

                until i == cal_count + 1 do
                  has[ta[i]] = has[ta[i]] + 1
                  i += 1
                end

                has[cal.event_end_at] = 0
                finish = 1
              end
              cal_count += 1
            end
          end
        end
      end

      ta.each do |time|
        if ((time <=> group.event_start_at) == -1) && (ta.index(group.event_start_at) == nil)
          ta.delete_at(ta.index(time))
          ta.insert(0, group.event_start_at)
          has[group.event_start_at] = 1
        elsif ((time <=> group.event_start_at) == -1) && (ta.index(group.event_start_at) != nil)
          ta.delete_at(ta.index(time))
          has[group.event_start_at] += has[time]
        end
      end

      ta1 = []

      ta.each do |time|
        if ((group.event_end_at <=> time) == -1) && (ta.index(group.event_end_at) == nil)
          ta.insert(-1, group.event_end_at)
          has[group.event_end_at] = 1
        elsif ((group.event_end_at <=> time) == -1) && (ta.index(group.event_end_at) != nil)
          has[group.event_end_at] += has[time]
        else
          ta1.push(time)
        end
      end

      timearray = []

      ta1.each{|time| timearray.push([date_format_transform(time), has[time]])}
      timearray
    end

    def self.date_format_transform(date)
      date = date.to_s
      date.gsub!(" ", "+")
      date.sub!("+", "T")
      date = date.split("++")

      date[0]
    end
  end
end
  