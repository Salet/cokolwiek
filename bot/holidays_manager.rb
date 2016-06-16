require 'active_support'

module HolidaysManager
  extend ActiveSupport::Concern

  @@unconfirmed_holiday = []
  @@confirmed_holiday = []
  included do
    command 'urlop' do |client, data, match|
      dates = match['expression'].split(' ').map(&:to_date)
      hash = { user: data.user, start_date: dates.first, end_date: dates.try(:second) }
      @@unconfirmed_holiday << hash
      @@unconfirmed_holiday.uniq!
      client.say(text: "<@#{hash[:user]}> poprosił o urlop w następujących dniach: #{hash[:start_date]} - #{hash[:end_date]}, (#{(hash[:end_date].present? ? (hash[:end_date] - hash[:start_date]) : 1).to_i} dni). Wpisz ok lub spadaj.", channel: admin_im(client))
      client.say(text: 'Prośba o urlop wysłana', channel: data.channel)
    end

    command 'urlopy dzisiaj' do |client, data, _match|
      response = @@confirmed_holiday.select do |i|
        if i[:end_date].present?
          (i[:start_date]..i[:end_date]).cover?(Date.today)
        else
          i[:start_date] == Date.today
        end
      end
      client.say(text: (format_holidays(response) || 'Brak'), channel: data.channel)
    end
    command 'urlopy' do |client, data, _match|
      client.say(text: (format_holidays || 'Brak'), channel: data.channel)
    end

    command 'ok' do |client, data, _match|
      if data.user == admin(client)
        hash = @@unconfirmed_holiday.shift
        @@confirmed_holiday << hash
        client.say(text: "<@#{hash[:user]}>: #{hash[:start_date]} - #{hash[:end_date]} - POTWIERDZONO", channel: admin_im(client))
        client.say(text: "<@#{hash[:user]}>: #{hash[:start_date]} - #{hash[:end_date]} - POTWIERDZONO", channel: user_im(hash[:user], client))
      end
    end

    command 'spadaj' do |client, data, _match|
      if data.user == admin(client)
        hash = @@unconfirmed_holiday.shift
        client.say(text: "<@#{hash[:user]}>: #{hash[:start_date]} - #{hash[:end_date]} - ODRZUCONO", channel: admin_im(client))
        client.say(text: "<@#{hash[:user]}>: #{hash[:start_date]} - #{hash[:end_date]} - ODRZUCONO", channel: user_im(hash[:user], client))
      end
    end

    def self.format_holidays(hash = @@confirmed_holiday)
      return nil if hash.empty?
      hash.sort_by { |item| item[:start_date] }
          .map { |item| "<@#{item[:user]}>: #{item[:start_date]} - #{item[:end_date]}" }.join("\n")
    end
  end
end
