require_relative '../ally'
require 'json'

module Ally
  class CloudinaryClient
    extend Ally

    attr_accessor :auth

    def initialize(config_path: "#{Ally::ROOT_DIR}/cloudinary.yml")
      unless ENV['CLOUDINARY_AUTH_JSON']
        raise ArgumentError, "config_path file not found" unless File.exist?(config_path)
        Ally.logger.info "No ENV['CLOUDINARY_AUTH_JSON'] detected, creating ENV var from file"
        cloudinary_yaml = YAML.load(File.read(config_path))
        ENV['CLOUDINARY_AUTH_JSON'] ||= begin
          JSON.dump(cloudinary_yaml["development"])
        rescue
          raise StandardError, "config_path file missing data or incorrectly formatted"
        end
      end

      # Parse the JSON config for CLOUDINARY_AUTH into the expected Ruby hash;
      # raise an error if it is unable to be parsed properly
      cloudinary_auth = {}
      Ally.logger.debug( "Cloudinary about to invoke JSON.parse; cloudinary_auth: #{cloudinary_auth} (should be an empty hash)" )
      begin
        JSON.parse(ENV['CLOUDINARY_AUTH_JSON']).each{|k,v| cloudinary_auth[k.to_sym]=v}
      rescue
        raise StandardError, "Unable to parse CLOUDINARY_AUTH_JSON ENV variable"
      end
      @auth ||= cloudinary_auth
    end

  end
end
