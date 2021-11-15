require 'spec_helper'
require 'lib/google_client'

describe Ally::GoogleClient do

  let(:google_client) { Ally::GoogleClient.new }
  init_google_client_secret = ENV['GOOGLE_CLIENT_SECRET']

  describe '.new' do

    it 'should create a new instance with valid params' do
      # Redefinie the original ENV var value for GOOGLE_CLIENT_SECRET
      ENV['GOOGLE_CLIENT_SECRET'] = init_google_client_secret
      expect( google_client ).to_not be(nil)
      expect{ google_client }.not_to raise_error
      expect( google_client.class ).to eq(Ally::GoogleClient)
    end

  end

  describe '.initialize' do

    it 'should require a valid config_path if no ENV configuration is found' do
      # Unset default `.env` values to ensure it blows up if they don't exist
      ENV['GOOGLE_CLIENT_SECRET'] = nil
      expect { Ally::GoogleClient.new(config_path: '') }.to raise_error(ArgumentError, 'config_path file not found')
    end

    it 'should raise an error if GOOGLE_CLIENT_SECRET is nil or empty' do
      # For this spec to pass we need a file that is always known to exist, but
      # will return nothing every time, /dev/null seems perfect for this
      ENV['GOOGLE_CLIENT_SECRET'] = nil
      expect { Ally::GoogleClient.new(config_path: '/dev/null') }.to raise_error(StandardError, 'Invalid Google client secret configuration')
      ENV['GOOGLE_CLIENT_SECRET'] = ''
      expect { Ally::GoogleClient.new(config_path: '/dev/null') }.to raise_error(StandardError, 'Invalid Google client secret configuration')
    end

  end

  describe '.session' do

    it 'should return a valid GoogleDrive session' do
      # Redefinie the original ENV var value for GOOGLE_CLIENT_SECRET
      ENV['GOOGLE_CLIENT_SECRET'] = init_google_client_secret
      expect( google_client.session ).to_not be(nil)
      expect( google_client.session.class ).to eq(GoogleDrive::Session)
    end

  end

end

