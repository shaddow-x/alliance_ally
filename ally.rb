# Load the always required gems
require 'bundler/setup'
# Only include :development if RUBY_ENV not defined, mimics Rails
Bundler.require(:default, ENV.fetch('RUBY_ENV', :development).to_sym)
if defined?(Dotenv)
  Dotenv.load
end

module Ally
  ################
  # Setup Logger #
  ################

  require 'logger'
  require 'awesome_print/core_ext/logger'

  #############
  # CONSTANTS #
  #############

  ROOT_DIR = File.expand_path(File.dirname(__FILE__)) unless defined?(ROOT_DIR)
  LIB_DIR  = File.expand_path(File.join(ROOT_DIR, 'lib')) unless defined?(LIB_DIR)
  APP_DIR  = File.expand_path(File.join(ROOT_DIR, 'app')) unless defined?(APP_DIR)
  BIN_DIR  = File.expand_path(File.join(ROOT_DIR, 'bin')) unless defined?(BIN_DIR)

  # Load the paths!
  [ROOT_DIR, LIB_DIR, APP_DIR, BIN_DIR].each do |dir|
    # Inject each directory into the $LOAD_PATH
    $LOAD_PATH.unshift(dir)
    # Require all files within /lib and /app only
    next unless [LIB_DIR, APP_DIR].include?(dir)
    #@logger.debug( "Requiring all files from: #{dir}" )
    Dir[File.join(dir, '*.rb')].each {|file| require File.basename(file) }
  end

  #########################
  # Define module methods #
  #########################

  def self.logger
    # Create the logger unless already defined
    self.send(:logger=) unless class_variable_defined?(:@@logger)

    @@logger
  end

  def self.logger=(log_level="INFO")
    logger = Logger.new($stdout)
    # Use ENV setting for logger if present, else use log_level param
    logger.level = ENV['LOG_LEVEL'] || log_level
    logger.debug "Ally#logger.level: #{ENV['LOG_LEVEL'] || log_level}"
    class_variable_set(:@@logger, logger)

    @@logger
  end
end
