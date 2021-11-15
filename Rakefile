#!/usr/bin/env rake

require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'optparse'
require 'base64'
require 'json'
require 'yaml'

task default: %i[spec]
#TODO: task default: %i[spec rubocop]

desc 'Run specs'
RSpec::Core::RakeTask.new(:spec)

desc 'Run rubocop'
task :rubocop do
  RuboCop::RakeTask.new
end

desc "Base64 encode the client_secret.json file"
task :encode_google_client_secret do
  puts Base64.strict_encode64(File.open("client_secret.json").read).gsub(/\n/,"")
end

desc "Convert cloudinary auth YAML to JSON string"
task :cloudinary_auth_to_string do
  cloudinary_yaml = YAML.load(File.read('cloudinary.yml'))
  puts "Copy and paste the following string into your production server's ENV variable for CLOUDINARY_AUTH_JSON:\r\n"
  puts JSON.dump(cloudinary_yaml['production'])
  exit 0
end

desc 'Display TODOs, FIXMEs, and OPTIMIZEs'
task :notes do
  system("grep -r 'OPTIMIZE:\\|FIXME:\\|TODO:' #{Dir.pwd}")
end
