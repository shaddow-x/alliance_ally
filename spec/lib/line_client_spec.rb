require 'spec_helper'
require 'lib/line_client'

describe Ally::LineClient do

  before(:each) do
    # Unset default `.env` values to ensure it blows up if they don't exist
    ENV['LINE_CHANNEL_SECRET'] = nil
    ENV['LINE_CHANNEL_TOKEN'] = nil
  end

  let(:line_client) { Ally::LineClient.new(channel_secret: 'secret', channel_token: 'token') }

  describe '.new' do

    it 'should create a new instance with valid params' do
      expect( line_client ).to_not be(nil)
      expect{ line_client }.not_to raise_error
      expect( line_client.class ).to eq(Ally::LineClient)
    end

  end

  describe '.initialize' do

    it 'should require channel_secret' do
      expect { Ally::LineClient.new(channel_secret: nil, channel_token: 'test') }.to raise_error(ArgumentError, 'channel_secret is required')
    end

    it 'should require channel_token' do
      expect { Ally::LineClient.new(channel_secret: 'test', channel_token: nil) }.to raise_error(ArgumentError, 'channel_token is required')
    end

  end

  describe '.client' do

    it 'should return a valid LINE client instance' do
      expect( line_client.client ).to_not be(nil)
      expect( line_client.client.class ).to eq(Line::Bot::Client)
    end

  end

end
