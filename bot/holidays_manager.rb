require 'active_support'
require 'chronic'

module HolidaysManager
  extend ActiveSupport::Concern
  @@unconfirmed_holiday = []
  @@confirmed_holiday = []
  included do
    command 'holiday' do |client, data, match|
      dates = match['expression'].split(' ').map { |string| Chronic.parse(string).to_date }
      hash = { user: data.user, start_date: dates.first, end_date: dates.try(:second) }
      @@unconfirmed_holiday << hash
      @@unconfirmed_holiday.uniq!
      client.say(text: "<@#{hash[:user]}> asked for holiday: #{hash[:start_date]} - #{hash[:end_date]}, (#{(hash[:end_date].present? ? (hash[:end_date] - hash[:start_date]) : 1).to_i} days). Type _ok_ or _nope_.", channel: admin_im(client))
      client.say(text: 'Holiday request sent!', channel: data.channel)
    end

    command 'holidays' do |client, data, match|
      if match['expression'].present?
        date = Chronic.parse(match['expression']).to_date
        response = @@confirmed_holiday.select do |item|
          if item[:end_date].present?
            (item[:start_date]..item[:end_date]).cover?(date)
          else
            item[:start_date] == date
          end
        end
        client.say(text: (format_holidays(response) || 'None'), channel: data.channel)
      else
        client.say(text: (format_holidays || 'None'), channel: data.channel)
      end
    end

    command 'ok' do |client, data, _match|
      if data.user == admin(client)
        hash = @@unconfirmed_holiday.shift
        @@confirmed_holiday << hash
        message = "<@#{hash[:user]}>: #{hash[:start_date]} - #{hash[:end_date]} - *Confirmed*"
        client.say(text: message, channel: admin_im(client))
        client.say(text: message, channel: user_im(hash[:user], client))
      end
    end

    command 'nope' do |client, data, _match|
      if data.user == admin(client)
        hash = @@unconfirmed_holiday.shift
        message = "<@#{hash[:user]}>: #{hash[:start_date]} - #{hash[:end_date]} - *REJECTED*"
        client.say(text: message, channel: admin_im(client))
        client.say(text: message, channel: user_im(hash[:user], client))
      end
    end

    def self.format_holidays(hash = @@confirmed_holiday)
      return nil if hash.empty?
      hash.sort_by { |item| item[:start_date] }
          .map { |item| "<@#{item[:user]}>: #{item[:start_date]} - #{item[:end_date]}" }.join("\n")
    end
  end
end
