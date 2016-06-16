require 'active_support'
require 'chronic'
require 'pry'

module PlanningManager
  extend ActiveSupport::Concern
  @@points = {}
  included do
    command 'planning start', 'planning restart' do |client, data, match|
      client.say(text: "Planning round started #{match['expression']}", channel: planning_channel(client))
      @@points = {}
    end

    command 'vote' do |client, data, match|
      @@points[data.user] = match['expression'].to_i if match['expression'].to_i
      client.say(text: "<@#{data.user}> voted, have *#{@@points.size}* votes", channel: planning_channel(client))
    end

    command 'planning stop', 'planning end', 'planning finish' do |client, data, _match|
      message = @@points.sort_by { |_k, v| v }.map { |k, v| "<@#{k}>: *#{v}*" }.join("\n")
      client.say(text: message, channel: planning_channel(client))
      @@points = {}
    end

    def self.planning_channel(client)
      @planning_channel ||= client.channels.find { |k, v| v['name'] == 'planning'}.first
    end
  end
end
