# Coverage
require 'simplecov'
SimpleCov.start do
  add_filter 'spec'
  add_filter 'bin'
end

# Setup HTTP request recordings for playback
require 'vcr'
VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcrs'
  config.hook_into :webmock
  config.filter_sensitive_data('<CLOUDINARY_API_KEY>') { ENV['CLOUDINARY_API_KEY'] }
  config.filter_sensitive_data('<CLOUDINARY_API_SECRET>') { ENV['CLOUDINARY_API_SECRET'] }
  config.default_cassette_options = {
    decode_compressed_response: true,
    allow_unused_http_interactions: false,
    serialize_with: :yaml
  }
end

# Must include '../ally' no lower than this line to be picked up...
# Possibly due to $LOAD_PATH edits in that file?
require_relative '../ally' # Require all the files, etc.

@spec_dir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(@spec_dir)
Dir[File.join(@spec_dir, '*.rb')].each {|file| require File.basename(file) }
$LOAD_PATH.uniq!

require 'rspec'
#require 'logging'
#require 'rspec/logging_helper'

# Spec Config
RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.filter_run_excluding :skip
  config.order = 'random'
  config.mock_with :rspec do |mocks|
    # Verified Instance Doubles
    mocks.verify_doubled_constant_names = true
  end

  # Configure RSpec to capture log messages for each test. The output from the
  # logs will be stored in the @log_output variable. It is a StringIO instance.
  #include RSpec::LoggingHelper
  #config.capture_log_messages
end
