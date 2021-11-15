require 'spec_helper'
require 'app/alliance'

describe Ally::Alliance do

  let(:alliance) { Ally::Alliance.new(tag: 'AABOT') }

  before(:each) do
  end

  context 'Validation' do

    it 'should require an alliance tag' do
      expect{ Ally::Alliance.new(tag: nil) }.to raise_error(Ally::Alliance::InvalidParams, 'Missing alliance tag')
    end

  end

  context '.new' do

    it 'should create a new alliance with valid params' do
      pending '#TODO: Should capture the google auth and return mock response'
      fail
      expect( alliance ).to_not be(nil)
      expect{ alliance }.not_to raise_error
      expect( alliance.class ).to eq(Ally::Alliance)



#      VCR.use_cassette("cloudinary-AABOT") do
#        # Disable ENV config for Cloudinary
#        ENV['CLOUDINARY_AUTH_JSON'] = nil
#        expect{ Ally::BotCommand.new(command: 'map7', opts: ['v1', 'bG2', 'AABOT']).excelsior! }
#          .to_not raise_error
#        expect( Ally::BotCommand.new(command: 'map7', opts: ['v1', 'bG2', 'AABOT']).excelsior! )
#          .to include({:altText => "Map 7", :template => {:columns => [{:action => {:label => "T1", :type => "uri", :uri => "https://res.cloudinary.com/alliance-ally/image/upload/v1631573181/alliances/AABOT/AABOT-v1-bg2_t1.png"}, :imageUrl=>"https://res.cloudinary.com/alliance-ally/image/upload/v1631573181/alliances/AABOT/AABOT-v1-bg2_t1.png"}, {:action=>{:label=>"T2", :type=>"uri", :uri=>"https://res.cloudinary.com/alliance-ally/image/upload/v1631573274/alliances/AABOT/AABOT-v1-bg2_t2.png"}, :imageUrl=>"https://res.cloudinary.com/alliance-ally/image/upload/v1631573274/alliances/AABOT/AABOT-v1-bg2_t2.png"}, {:action=>{:label=>"T3", :type=>"uri", :uri=>"https://res.cloudinary.com/alliance-ally/image/upload/v1631573328/alliances/AABOT/AABOT-v1-bg2_t3.png"}, :imageUrl=>"https://res.cloudinary.com/alliance-ally/image/upload/v1631573328/alliances/AABOT/AABOT-v1-bg2_t3.png"}], :type=>"image_carousel"}, :type => "template"})
#      end

    end

  end

end
