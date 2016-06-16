require 'active_support'
require 'chronic'

module EventManager
  extend ActiveSupport::Concern

  @@events = []

  included do

    command 'events', 'current events' do |client, data, match|
      if @@events.any?
        @@events.each do |e|
          text = "#{e[:name]} - #{e[:description]} learn more at #{e[:link]}"
          client.say(text: text, channel: data.channel)
        end
      else
        client.say(text: "No events planned", channel: data.channel)
      end
    end

    command 'add event' do |client, data, match|
      if data.user == admin(client)
        values = match['expression'].split('|')
        keys = [:name, :description, :link]
        @@events << Hash[*keys.zip(values).flatten]
        client.say(text: "Event added", channel: data.channel)
      end
    end
  end
end
