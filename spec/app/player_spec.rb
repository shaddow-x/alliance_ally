require 'spec_helper'
require 'app/player'

describe Ally::Player do

  let(:player) { Ally::Player.new() }

  before(:each) do
    player_id = 'Shaddow X'.to_str.parameterize.underscore
    @p1 ||= Ally::Player.new(str_id: "#{player_id}-1", alliance: "AABOT", bg: 1)
    @p2 ||= Ally::Player.new(str_id: "#{player_id}-2", alliance: "AABOT", bg: 2)
    @p3 ||= Ally::Player.new(str_id: "#{player_id}-3", alliance: "AABOT", bg: 3)
    @p4 ||= Ally::Player.new(str_id: "#{player_id}-4", alliance: "AABOT", bg: 1)
    @p5 ||= Ally::Player.new(str_id: "#{player_id}-5", alliance: "AABOT", bg: 1)
  end

  describe '.new' do

    it 'should create a new instance with valid params' do
      expect( player ).to_not be(nil)
      expect{ player }.not_to raise_error
      expect( player.class ).to eq(Ally::Player)
    end

    it 'should expect all params to be set when passed in' do
      #attr_accessor :str_id, :name, :prestige, :timezone, :bg, :notes, :path_likes, :path_dislikes
      pending('verify a new player instance w/ all optional params passed in returns all params with the respective getter')
      fail
    end

    # Testing these using spec/custom_matchers/should_have_attr_accessor.rb
    #it { should have_attr_accessor(:str_id) }
    #it { should have_attr_accessor(:name) }
    #it { should have_attr_accessor(:prestige) }
    #it { should have_attr_accessor(:timezone) }
    #it { should have_attr_accessor(:bg) }
    #it { should have_attr_accessor(:notes) }
    #it { should have_attr_accessor(:path_likes) }
    #it { should have_attr_accessor(:path_dislikes) }

  end

  describe '.initialize' do

    it 'should require a player to have a string ID' do
      pending("should require a player to have a string ID")
      fail
    end

    it 'should require a player to have an alliance' do
      pending('should require a player to have an alliance')
      fail
    end

    it 'should require a player to have a BG' do
      pending('should require a player to have a BG')
      fail
    end

    it 'should require a player to have a name' do
      pending('should require a player to have a name')
      fail
    end

    it 'should verify that str_id is unique' do
      pending('should verify that str_id is unique')
      fail
    end

  end

  describe '#all' do

    it 'should return all players created' do
      expect( Ally::Player.all.map(&:str_id).uniq.compact ).to eq(["shaddow_x-1", "shaddow_x-2", "shaddow_x-3", "shaddow_x-4", "shaddow_x-5"])
    end

  end

end
