require 'slack-ruby-bot'
require 'active_support'
require 'pry'
require 'chronic'

require_relative 'holidays_manager'

class PongBot < SlackRubyBot::Bot
  include HolidaysManager

  HOMEOFFICE = {}

  def self.admin(client)
    @@admin_id ||= client.users.find { |_k, v| v['name'] == 'wojtek' }.first
  end

  def self.admin_im(client)
    @@admin_im ||= client.ims.find { |_k, v| v['user'] == admin(client) }.first
  end

  def self.user_im(user_id, client)
    client.ims.find { |_k, v| v['user'] == user_id }.first
  end

  command 'homeoffice' do |client, data, match|
    client.say(text: "Hello <@#{data.user}>, #{match['expression']}", channel: data.channel)
  end
end

PongBot.run
