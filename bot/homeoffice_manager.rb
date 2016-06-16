require 'active_support'
require 'chronic'

module HomeofficeManager
  extend ActiveSupport::Concern

  HOMEOFFICE = {}
  IGNORED = ['USLACKBOT']

  included do

    command 'homeoffice check', 'homeoffice who' do |client, data, match|
      client.say(text: "Najpierw **podaj datę!**", channel: data.channel) if match['expression'].nil?

      date = Chronic.parse(match['expression'])
      home_people = HOMEOFFICE[date].to_a
      office_people = client.users.select{ |k, v| v["is_bot"] == false }.keys - IGNORED - home_people

      if home_people.any?
        home_people_names = home_people.map { |person| "<@#{person}>"}.join(', ')
        office_people_names = office_people.map { |person| "<@#{person}>"}.join(', ')
        client.say(text: "*#{date.to_date}* z domu pracują: #{home_people_names}", channel: data.channel)
        client.say(text: "W biurze *powinni być*: #{office_people_names}, inaczej wpierdziel", channel: data.channel)
      else
        client.say(text: "*#{date.to_date}* wszyscy są w biurze! (taa...)", channel: data.channel)
      end
    end

    command 'homeoffice at', 'homeoffice', 'homeoffice add' do |client, data, match|
      client.say(text: "Najpierw *podaj datę!*", channel: data.channel) if match['expression'].nil?

      date = Chronic.parse(match['expression'])
      HOMEOFFICE[date] = [] if HOMEOFFICE[date].blank?
      HOMEOFFICE[date] << data.user unless HOMEOFFICE[date].include?(data.user)
      client.say(text: "*#{date.to_date}* pracujesz z domu!", channel: data.channel)
    end

  end
end
