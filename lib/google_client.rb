require_relative '../ally'
require 'base64'

module Ally
  class GoogleClient
    extend Ally

    attr_accessor :session

    def initialize(config_path: "#{Ally::ROOT_DIR}/client_secret.json")
      Ally.logger.debug "config_path set to: #{config_path}"
      # Base64 encode the client_secret JSON file into the ENV
      unless ENV['GOOGLE_CLIENT_SECRET']
        raise ArgumentError, "config_path file not found" unless File.exist?(config_path)
        Ally.logger.info "No ENV['GOOGLE_CLIENT_SECRET'] detected, creating ENV var from config_path file"
        ENV['GOOGLE_CLIENT_SECRET'] = Base64.strict_encode64(File.read("#{config_path}")).gsub(/\n/,"")
      end

      # Verify that the GOOGLE_CLIENT_SECRET ENV variable is defined or raise an error
      if ENV['GOOGLE_CLIENT_SECRET'].nil? || ENV['GOOGLE_CLIENT_SECRET'].empty?
        raise StandardError, "Invalid Google client secret configuration"
      end

      Ally.logger.debug "Creating google_config from base64 encoded client_secret..."
      google_config = StringIO.new(Base64.decode64(ENV['GOOGLE_CLIENT_SECRET']))
      Ally.logger.debug "google_config: #{google_config}"
      # Create a session with Google Service Account for Google Drive
      @session ||= GoogleDrive::Session.from_service_account_key(google_config)
    end

  end
end
