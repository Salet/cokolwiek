require 'slack-ruby-bot'
require_relative 'holidays_manager'
require_relative 'homeoffice_manager'

class PongBot < SlackRubyBot::Bot
  command 'help' do |client, data, match|
    client.say(text:
    'Exlabs office manager. Usage:

    *Holidays* - request holidays and list all holidays that have already been confirmed
    `holiday <date> <date>`
      Request holiday between given dates. Example `holiday 30-06-16 07-07-16`

    `holidays`, `holidays <date>`
      Lists all confirmed holiday breaks, or check who is on holiday at a given date.


    *Home Office* - specify when are you going to be working from home and who will be in the office at a given date
    `homeoffice check <date>`, `homeoffice who <date>`
      Lists users that are going to be working from home at a given date.

    `homeoffice <date>`, `homeoffice at <date>`, `homeoffice add <date>`
      Sets you as working from home on a given date.
      ', channel: data.channel)
  end

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
