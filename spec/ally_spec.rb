require 'spec_helper'
#require_relative '../ally'

describe Ally do

  context '#logger' do

    #subject { described_class }
    it { should respond_to :logger }
    it { should respond_to :logger= }

    it 'should return an instance of Logger' do
      expect( subject.logger.class ).to eq( Logger )
    end

    it '#logger= should create a new Logger' do
      expect( subject.send(:logger=).class ).to eq(Logger)
    end

  end

  context 'Verify LOG_LEVELs work:' do
    before(:each) do
      # Unset any `.env` logger settings to be safe
      ENV['LOG_LEVEL'] = nil
      # Unset the cached @@logger value
      subject.class_variable_set(:@@logger, nil)
    end

    after(:each) do
      # Reset whatever ENV['LOG_LEVEL'] was just tested
      subject.class_variable_set(:@@logger, nil)
      subject.logger=()
    end

    it 'should be set to logger level 3 when LOG_LEVEL == ERROR' do
      #Simulate ENV['LOG_LEVEL'] = 'ERROR'
      ENV['LOG_LEVEL'] = "ERROR"
      subject.logger=()
      expect( subject.logger.level ).to eq(3)
    end

    it 'should be set to logger level 2 when LOG_LEVEL == WARN' do
      ENV['LOG_LEVEL'] = 'WARN'
      subject.logger=()
      expect( subject.logger.level ).to eq(2)
    end

    it 'should be set to logger level 1 when LOG_LEVEL == INFO' do
      ENV['LOG_LEVEL'] = 'INFO'
      subject.logger=()
      expect( subject.logger.level ).to eq(1)
    end

    it 'should be set to logger level 0 when LOG_LEVEL == DEBUG' do
      ENV['LOG_LEVEL'] = 'DEBUG'
      subject.logger=()
      expect( subject.logger.level ).to eq(0)
    end
  end

  context '$LOAD_PATH' do
    ROOT_DIR = Pathname.getwd # Use this to the parent directory
    #load 'ally.rb'
    let(:load_path_dirs) { $LOAD_PATH.uniq.join(" ").to_s }

    it 'should include the app directory' do
      expect(load_path_dirs).to include("#{ROOT_DIR}/app")
    end

    it 'should include the bin directory' do
      expect(load_path_dirs).to include("#{ROOT_DIR}/bin")
    end

    it 'should include the lib directory' do
      expect(load_path_dirs).to include("#{ROOT_DIR}/lib")
    end
  end

end
