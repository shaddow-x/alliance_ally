#!/usr/bin/env ruby
require_relative '../ally'
require 'line/bot'

module Ally
  class LineClient
    extend Ally

    attr_accessor :channel_secret, :channel_token, :client

    def initialize(channel_secret: nil, channel_token: nil)
      # Use ENV variables for config if present
      @channel_secret = ENV["LINE_CHANNEL_SECRET"] || channel_secret
      @channel_token = ENV["LINE_CHANNEL_TOKEN"] || channel_token
      raise ArgumentError, "channel_secret is required" if @channel_secret.nil?
      raise ArgumentError, "channel_token is required" if @channel_token.nil?
    end

    def client
      # LINE client config & default parsing
      @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = @channel_secret
        config.channel_token = @channel_token
      }
    end

  end
end
