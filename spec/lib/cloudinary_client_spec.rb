require 'spec_helper'
require 'lib/cloudinary_client'

describe Ally::CloudinaryClient do

  let(:cloudinary_client) { Ally::CloudinaryClient.new() }
  init_cloudinary_auth_json = ENV['CLOUDINARY_AUTH_JSON']

  describe '.new' do

    it 'should create a new instance with valid params' do
      # Redefinie the original ENV var value for CLOUDINARY_AUTH_JSON
      ENV['CLOUDINARY_AUTH_JSON'] = init_cloudinary_auth_json
      expect( cloudinary_client ).to_not be(nil)
      expect{ cloudinary_client }.not_to raise_error
      expect( cloudinary_client.class ).to eq(Ally::CloudinaryClient)
    end

  end

  describe '.initialize' do

    it 'should require a valid config_path if no ENV configuration is found' do
      # Unset default `.env` values to ensure it blows up if they don't exist
      ENV['CLOUDINARY_AUTH_JSON'] = nil
      expect { Ally::CloudinaryClient.new(config_path: '') }
        .to raise_error(ArgumentError, 'config_path file not found')
      expect { Ally::CloudinaryClient.new(config_path: '/dev/null') }
        .to raise_error(StandardError, 'config_path file missing data or incorrectly formatted')
    end

    it 'should raise an error if it is unable to parse the CLOUDINARY_AUTH_JSON ENV variable' do
      # Unset default `.env` values to ensure it blows up if they don't exist
      ENV['CLOUDINARY_AUTH_JSON'] = 'bad data'
      expect { Ally::CloudinaryClient.new(config_path: '') }
        .to raise_error(StandardError, 'Unable to parse CLOUDINARY_AUTH_JSON ENV variable')
    end

  end

  describe '.auth' do

    it 'should return the cloudinary auth configuration' do
      # Redefinie the original ENV var value for CLOUDINARY_AUTH_JSON
      ENV['CLOUDINARY_AUTH_JSON'] = init_cloudinary_auth_json
      expect( cloudinary_client.auth ).to_not be(nil)
      expect{ cloudinary_client.auth }.not_to raise_error
      expect( cloudinary_client.auth.class ).to eq(Hash)
    end

  end

end
