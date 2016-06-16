require 'slack-ruby-bot'
require 'active_support'
require 'pry'
require 'chronic'

class PongBot < SlackRubyBot::Bot
  HOMEOFFICE = {}

  command 'ping' do |client, data, match|
    client.say(text: 'pong', channel: data.channel)
  end

  command 'homeoffice' do |client, data, match|
    client.say(text: "Hello <@#{data.user}>, #{match['expression']}", channel: data.channel)
  end
end

PongBot.run
