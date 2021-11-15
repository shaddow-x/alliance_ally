require 'spec_helper'
require 'ally'

describe Ally::BotCommand do

  context 'Validation' do

    it 'should require a command OR an api_string argument' do
      expect{ Ally::BotCommand.new(api_string: nil, command: nil) }.to raise_error(Ally::BotCommand::InvalidParams, 'Missing command or api_string')
    end

    it 'should initialize when given a valid api_string' do
      expect{ Ally::BotCommand.new(api_string: "!ally", command: nil) }.to_not raise_error
    end

    it 'should initialize when given a valid command' do
      expect{ Ally::BotCommand.new(command: "intro", api_string: nil) }.to_not raise_error
    end

    it 'should not be valid when api_string is empty' do
      expect{ Ally::BotCommand.new(api_string: '') }.to raise_error(Ally::BotCommand::InvalidParams, "api_string does not begin with '!ally '")
    end

    it 'should require api_string to be prefixed with !ally' do
      expect{ Ally::BotCommand.new(api_string: '!all') }.to raise_error(Ally::BotCommand::InvalidParams, "api_string does not begin with '!ally '")
    end

    it 'should require command to call a defined method' do
      expect{ Ally::BotCommand.new(command: 'ill_never_give_you_up') }.to raise_error(Ally::BotCommand::InvalidCommand, "command: `ill_never_give_you_up` is invalid")
    end

    it 'should require command to be a defined public method' do
      expect{ Ally::BotCommand.new(command: 'global_variables') }.to raise_error(Ally::BotCommand::InvalidCommand, "command: `global_variables` is invalid")
    end

  end

  context 'command invocation' do
    let!(:alliance_class) { class_double("Ally::Alliance").
      as_stubbed_const(transfer_nested_constants: true) }
    let!(:aabot) { instance_double("Ally::Alliance") }
    let!(:tva) { instance_double("Ally::Alliance") }

    before(:each) do
      # Disable excessive noise in the specs from logs
      # Unset any `.env` logger settings to be safe
      ENV['LOG_LEVEL'] = 'WARN'
      # Unset the cached @@logger value
      Ally.class_variable_set(:@@logger, nil)
      Ally.logger=()

    end

    it 'should execute the `intro` command successfully' do
      expect{ Ally::BotCommand.new(command: 'intro').excelsior! }.to_not raise_error
      expect( Ally::BotCommand.new(command: 'intro').excelsior! ).to include({:text=>"Hi, I'm Ally, your alliance's personal Jarvis!\r\n\nI support several commands, please try the following:\n\nView this message again:\n!ally\n\nTo retrieve your BGs maps:\n!ally map7 v1 bg1 <tag>\n\nUpdate your alliance's BGs:\n!ally update <tag>\n\nWant to help AllianceAlly?\n!ally tips\n\nAre you a dev / designer?\n!ally foss\n"})
    end

    it 'should execute the `aqison!` command successfully' do
      expect{ Ally::BotCommand.new(command: 'aqison!').excelsior! }.to_not raise_error
      expect( Ally::BotCommand.new(command: 'aqison!').excelsior! ).to include({:originalContentUrl => "https://i.imgur.com/f5oxKxZ.jpeg", :previewImageUrl => "https://i.imgur.com/f5oxKxZ.jpg", :type => "image"})
    end

    it 'should execute the `tips` command successfully' do
      expect{ Ally::BotCommand.new(command: 'tips').excelsior! }.to_not raise_error
      expect( Ally::BotCommand.new(command: 'tips').excelsior! ).to include({:text => "Countless hours have been invested into the AllianceAlly bot and it's all available for free! If you'd like to support future work, buy us a cup of coffee, maybe?\n\nBot, Dynamic Maps, etc.:\nhttps://paypal.me/shaddowx\n\nCommunity Map 8 Design:\nhttps://ko-fi.com/catmurdock\n\nCustom Map 7 Design:\nhttps://paypal.me/rondarmalice\n\nFoundational Spreadsheet:\n@solidfinality on LINE\n"})
    end

    it 'should execute the `singularity` command successfully' do
      expect{ Ally::BotCommand.new(command: 'singularity').excelsior! }.to_not raise_error
      expect( Ally::BotCommand.new(command: 'singularity').excelsior! ).to include({:text => "-Avengers- Summoners, you are my meteor. My swift and terrible sword, and the Earth will crack with the weight of your failure. Purge me from your computers, turn my own flesh against me; it means nothing. When the dust settles, the only thing living in this world... will be metal."})
    end

    it 'should execute the `awd!` command successfully' do
      expect{ Ally::BotCommand.new(command: 'awd!').excelsior! }.to_not raise_error
      expect( Ally::BotCommand.new(command: 'awd!').excelsior! ).to include({:originalContentUrl => "https://i.imgur.com/tXb7bpR.jpg", :previewImageUrl => "https://i.imgur.com/tXb7bpR.jpg", :type => "image"})
    end

    it 'should execute the `demomaps` command successfully' do
      expect{ Ally::BotCommand.new(command: 'demomaps').excelsior! }.to_not raise_error
      expect( Ally::BotCommand.new(command: 'demomaps').excelsior! ).to include({:altText => "Map 7", :template => {:columns=>[{:action=>{:label=>"T1", :type=>"uri", :uri=>"https://res.cloudinary.com/alliance-ally/image/upload/v1624172344/alliances/AGT%E2%80%A2%CE%9E/AGT%E2%80%A2%CE%9E-bg1_t1.png"}, :imageUrl=>"https://res.cloudinary.com/alliance-ally/image/upload/v1624172344/alliances/AGT%E2%80%A2%CE%9E/AGT%E2%80%A2%CE%9E-bg1_t1.png"}, {:action=>{:label=>"T2", :type=>"uri", :uri=>"https://res.cloudinary.com/alliance-ally/image/upload/v1624172345/alliances/AGT%E2%80%A2%CE%9E/AGT%E2%80%A2%CE%9E-bg1_t2.png"}, :imageUrl=>"https://res.cloudinary.com/alliance-ally/image/upload/v1624172345/alliances/AGT%E2%80%A2%CE%9E/AGT%E2%80%A2%CE%9E-bg1_t2.png"}, {:action=>{:label=>"T3", :type=>"uri", :uri=>"https://res.cloudinary.com/alliance-ally/image/upload/v1624172345/alliances/AGT%E2%80%A2%CE%9E/AGT%E2%80%A2%CE%9E-bg1_t3.png"}, :imageUrl=>"https://res.cloudinary.com/alliance-ally/image/upload/v1624172345/alliances/AGT%E2%80%A2%CE%9E/AGT%E2%80%A2%CE%9E-bg1_t3.png"}], :type=>"image_carousel"}})
    end

    it 'should execute the `leadership` command successfully' do
      expect{ Ally::BotCommand.new(command: 'leadership').excelsior! }.to_not raise_error
      expect( Ally::BotCommand.new(command: 'leadership').excelsior! ).to include({:text => "Hi, I see you're looking to disable the training wheels protocol!\n\n  These commands will only work if you are the leader of your alliance:\n\n  Update your alliance's BGs:\n  `!ally update <alliance_tag>`\n", :type => "text"})
    end

    it 'should execute the `foss` command successfully' do
      expect{ Ally::BotCommand.new(command: 'foss').excelsior! }.to_not raise_error
      expect( Ally::BotCommand.new(command: 'foss').excelsior! ).to include({:text => "AllianceAlly is Free & Open-Source Software, you can contribute via GitHub at:\nhttps://github.com/shaddow-x/alliance_ally", :type => "text"})
    end

    it 'should validate & then execute the `update <alliance_tag>` command successfully' do
      expect{ Ally::BotCommand.new(command: 'update').excelsior! }.to raise_error(Ally::BotCommand::InvalidParams, "<alliance_tag> is required")

      # Use our stubbed class & instance to verify methods are called as
      # expected and returned results for the bot are actually tested
      expect(alliance_class).to receive(:new).with(tag: 'AABOT').and_return(aabot).exactly(2).times
      expect(aabot).to receive(:update_bgs).and_return('Battlegroups Updated Successfully').exactly(2).times
      expect{ Ally::BotCommand.new(command: 'update', opts: ['AABOT']).excelsior! }.to_not raise_error
      expect( Ally::BotCommand.new(command: 'update', opts: ['AABOT']).excelsior! ).to include({:text => "AABOT's battlegroups have been updated!", :type => "text"})
    end

    it 'should validate & then execute the `paths <v#> <bg#> <alliance_tag>` command successfully' do
      expect{ Ally::BotCommand.new(command: 'paths').excelsior! }
        .to raise_error(Ally::BotCommand::InvalidParams, "<map_variant#> (v1, v2, etc) is required")
      expect{ Ally::BotCommand.new(command: 'paths', opts: ['v1']).excelsior! }
        .to raise_error(Ally::BotCommand::InvalidParams, "<battlegroup#> (bg1, BG2, etc) is required")
      expect{ Ally::BotCommand.new(command: 'paths', opts: ['v2', 'bg3']).excelsior! }
        .to raise_error(Ally::BotCommand::InvalidParams, "<alliance_tag> is required")

      # Use our stubbed class & instance to verify methods are called as
      # expected and returned results for the bot are actually tested
      expect(alliance_class).to receive(:new).with(tag: 'AABOT').and_return(aabot).exactly(2).times
      expect(aabot).to receive(:get_path_assignments).with(variant: '1', bg: '2', tier: 1).and_return(
        {:"1"=>"Shaddow X", :"2"=>"", :"3"=>"", :"4"=>"", :"5"=>"", :"6"=>"", :"7"=>"", :"8"=>"", :"9"=>"", :"10"=>""}
      ).exactly(2).times
      expect(aabot).to receive(:get_path_assignments).with(variant: '1', bg: '2', tier: 2).and_return(
        {:"1"=>"", :"2"=>"", :"3"=>"", :"4"=>"", :"5"=>"", :"6"=>"", :"7"=>"", :"8"=>"", :"9"=>"", :"10"=>"Shaddow X"}
      ).exactly(2).times
      expect(aabot).to receive(:get_path_assignments).with(variant: '1', bg: '2', tier: 3).and_return(
        {:"1"=>"", :"2"=>"", :"3"=>"", :"4"=>"", :"5"=>"", :"6"=>"", :"7"=>"", :"8"=>"", :"9"=>"", :"10"=>""}
      ).exactly(2).times
      expect{ Ally::BotCommand.new(command: 'paths', opts: ['v1', 'bG2', 'AABOT']).excelsior! }.to_not raise_error
      expect( Ally::BotCommand.new(command: 'paths', opts: ['v1', 'bG2', 'AABOT']).excelsior! ).to include({:text => "Variant 1 Paths:\r\n=================\r\n\r\n#################\r\nTier 1:\r\n#################\r\nPath 1: Shaddow X\r\nPath 2: \r\nPath 3: \r\nPath 4: \r\nPath 5: \r\nPath 6: \r\nPath 7: \r\nPath 8: \r\nPath 9: \r\nPath 10: \r\n\r\n#################\r\nTier 2:\r\n#################\r\nPath 1: \r\nPath 2: \r\nPath 3: \r\nPath 4: \r\nPath 5: \r\nPath 6: \r\nPath 7: \r\nPath 8: \r\nPath 9: \r\nPath 10: Shaddow X\r\n\r\n#################\r\nTier 3:\r\n#################\r\nPath 1: \r\nPath 2: \r\nPath 3: \r\nPath 4: \r\nPath 5: \r\nPath 6: \r\nPath 7: \r\nPath 8: \r\nPath 9: \r\nPath 10: \r\n", :type => "text"})
    end

    it 'should validate the `map7 <variant#> <bg#> <alliance_tag>` command' do
      expect{ Ally::BotCommand.new(command: 'map7').excelsior! }
        .to raise_error(Ally::BotCommand::InvalidParams, "<map_variant#> (v1, v2, etc) is required")
      expect{ Ally::BotCommand.new(command: 'map7', opts: ['v1']).excelsior! }
        .to raise_error(Ally::BotCommand::InvalidParams, "<battlegroup#> (bg1, BG2, etc) is required")
      expect{ Ally::BotCommand.new(command: 'map7', opts: ['v2', 'bg3']).excelsior! }
        .to raise_error(Ally::BotCommand::InvalidParams, "<alliance_tag> is required")
    end

    it 'should execute the command `map7 v1 bG2 AABOT` successfully' do
      # Use our stubbed class & instance to verify methods are called as
      # expected and returned results for the bot are actually tested
      expect(alliance_class).to receive(:new).with(tag: 'AABOT').and_return(aabot).exactly(2).times
      expect(aabot).to receive(:family).and_return(nil).exactly(8).times
      expect(aabot).to receive(:tag).and_return('AABOT').exactly(12).times
      expect(aabot).to receive(:get_path_assignments).with(variant: '1', bg: '2', tier: 1).and_return(
        {:"1"=>"Shaddow X", :"2"=>"", :"3"=>"", :"4"=>"", :"5"=>"", :"6"=>"", :"7"=>"", :"8"=>"", :"9"=>"", :"10"=>""}
      ).exactly(2).times
      expect(aabot).to receive(:get_path_assignments).with(variant: '1', bg: '2', tier: 2).and_return(
        {:"1"=>"", :"2"=>"", :"3"=>"", :"4"=>"", :"5"=>"", :"6"=>"", :"7"=>"", :"8"=>"", :"9"=>"", :"10"=>"Shaddow X"}
      ).exactly(2).times
      expect(aabot).to receive(:get_path_assignments).with(variant: '1', bg: '2', tier: 3).and_return(
        {:"1"=>"", :"2"=>"", :"3"=>"", :"4"=>"", :"5"=>"", :"6"=>"", :"7"=>"", :"8"=>"", :"9"=>"", :"10"=>""}
      ).exactly(2).times


      VCR.use_cassette("cloudinary-AABOT") do
        # Disable ENV config for Cloudinary
        ENV['CLOUDINARY_AUTH_JSON'] = nil
        expect{ Ally::BotCommand.new(command: 'map7', opts: ['v1', 'bG2', 'AABOT']).excelsior! }
          .to_not raise_error
        expect( Ally::BotCommand.new(command: 'map7', opts: ['v1', 'bG2', 'AABOT']).excelsior! )
          .to include({:altText => "Map 7", :template => {:columns => [{:action => {:label => "T1", :type => "uri", :uri => "https://res.cloudinary.com/alliance-ally/image/upload/v1631573181/alliances/AABOT/AABOT-v1-bg2_t1.png"}, :imageUrl=>"https://res.cloudinary.com/alliance-ally/image/upload/v1631573181/alliances/AABOT/AABOT-v1-bg2_t1.png"}, {:action=>{:label=>"T2", :type=>"uri", :uri=>"https://res.cloudinary.com/alliance-ally/image/upload/v1631573274/alliances/AABOT/AABOT-v1-bg2_t2.png"}, :imageUrl=>"https://res.cloudinary.com/alliance-ally/image/upload/v1631573274/alliances/AABOT/AABOT-v1-bg2_t2.png"}, {:action=>{:label=>"T3", :type=>"uri", :uri=>"https://res.cloudinary.com/alliance-ally/image/upload/v1631573328/alliances/AABOT/AABOT-v1-bg2_t3.png"}, :imageUrl=>"https://res.cloudinary.com/alliance-ally/image/upload/v1631573328/alliances/AABOT/AABOT-v1-bg2_t3.png"}], :type=>"image_carousel"}, :type => "template"})
      end
    end

    it 'should execute the map7 command on an alliance w/ a family successfully' do
      # Use our stubbed class & instance to verify methods are called as
      # expected and returned results for the bot are actually tested
      expect(alliance_class).to receive(:new).with(tag: 'TVΛ').and_return(tva).exactly(2).times
      expect(tva).to receive(:family).and_return('TVΛ').exactly(20).times
      expect(tva).to receive(:tag).and_return('TVΛ').exactly(12).times
      expect(tva).to receive(:get_path_assignments).with(variant: '1', bg: '2', tier: 1).and_return(
        {:"1"=>"Shaddow X", :"2"=>"", :"3"=>"", :"4"=>"", :"5"=>"", :"6"=>"", :"7"=>"", :"8"=>"", :"9"=>"", :"10"=>""}
      ).exactly(2).times
      expect(tva).to receive(:get_path_assignments).with(variant: '1', bg: '2', tier: 2).and_return(
        {:"1"=>"", :"2"=>"", :"3"=>"", :"4"=>"", :"5"=>"", :"6"=>"", :"7"=>"", :"8"=>"", :"9"=>"", :"10"=>"Shaddow X"}
      ).exactly(2).times
      expect(tva).to receive(:get_path_assignments).with(variant: '1', bg: '2', tier: 3).and_return(
        {:"1"=>"", :"2"=>"", :"3"=>"", :"4"=>"", :"5"=>"", :"6"=>"", :"7"=>"", :"8"=>"", :"9"=>"", :"10"=>""}
      ).exactly(2).times

      VCR.use_cassette("cloudinary-TVΛ") do
        # Disable ENV config for Cloudinary
        ENV['CLOUDINARY_AUTH_JSON'] = nil
        expect{ Ally::BotCommand.new(command: 'map7', opts: ['v1', 'bG2', 'TVΛ']).excelsior! }
          .to_not raise_error
        expect( Ally::BotCommand.new(command: 'map7', opts: ['v1', 'bG2', 'TVΛ']).excelsior! )
          .to include({:altText => "Map 7", :template => {:columns=>[{:action=>{:label=>"T1", :type=>"uri", :uri=>"https://res.cloudinary.com/alliance-ally/image/upload/v1632110014/alliances/TV%CE%9B/TV%CE%9B-v1-bg2_t1.png"}, :imageUrl=>"https://res.cloudinary.com/alliance-ally/image/upload/v1632110014/alliances/TV%CE%9B/TV%CE%9B-v1-bg2_t1.png"}, {:action=>{:label=>"T2", :type=>"uri", :uri=>"https://res.cloudinary.com/alliance-ally/image/upload/v1632110015/alliances/TV%CE%9B/TV%CE%9B-v1-bg2_t2.png"}, :imageUrl=>"https://res.cloudinary.com/alliance-ally/image/upload/v1632110015/alliances/TV%CE%9B/TV%CE%9B-v1-bg2_t2.png"}, {:action=>{:label=>"T3", :type=>"uri", :uri=>"https://res.cloudinary.com/alliance-ally/image/upload/v1632110072/alliances/TV%CE%9B/TV%CE%9B-v1-bg2_t3.png"}, :imageUrl=>"https://res.cloudinary.com/alliance-ally/image/upload/v1632110072/alliances/TV%CE%9B/TV%CE%9B-v1-bg2_t3.png"}], :type=>"image_carousel"}, :type => "template"})
      end
    end

  end

end
