require 'slack-ruby-bot'
require_relative 'holidays_manager'
require_relative 'homeoffice_manager'
require_relative 'events_manager'
require_relative 'planning_manager'

class PongBot < SlackRubyBot::Bot
  command 'help' do |client, data, match|
    client.say(text:
    'Work days manager
      Holidays
        request holidays and list all holidays that have been already confirmed

        holiday
          Request holiday
          specify start and end date like so: urlop YYYY-MM-DD YYYY-MM-DD

        holidays
          Lists all confirmed holiday breaks

      Office
        specify when you are gonna be in the office and check who else will be there

        homeoffice check, homeoffice who
          Lists users that are gonna be in the office on given date

        homeoffice at, homeoffice, homeoffice add
          Sets you as working from home on a given date

      Events
        check what events are planned and add new ones

        events
          list all upcoming events

      Planning
        vote for next thing to do

        planning start, planning restart
          starts a round of voting

        vote
          adds a vote for given option

        planning stop, planning end, planning finish
          stops a round of voting and shows the resoults
          ',channel: data.channel)
  end

  include HolidaysManager
  include HomeofficeManager
  include EventManager
  include PlanningManager

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
