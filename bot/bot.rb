require 'slack-ruby-bot'
require_relative 'holidays_manager'
require_relative 'homeoffice_manager'

class PongBot < SlackRubyBot::Bot
  include HolidaysManager
  include HomeofficeManager

  def self.admin(client)
    @@admin_id ||= client.users.find { |_k, v| v['name'] == 'wojtek' }.first
  end

  def self.admin_im(client)
    @@admin_im ||= client.ims.find { |_k, v| v['user'] == admin(client) }.first
  end

  def self.user_im(user_id, client)
    client.ims.find { |_k, v| v['user'] == user_id }.first
  end

end

PongBot.run
