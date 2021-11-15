#!/usr/bin/env -S falcon --verbose serve -c
# frozen_string_literal: true

require_relative 'ally'
require 'sinatra/base'
require 'line/bot'

class AllyBot < Sinatra::Base
  include Ally
  $stdout.sync = true # Heroku logging fix
  LINE = Ally::LineClient.new

  post '/line/callback' do
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless LINE.client.validate_signature(body, signature)
      halt 400, {'Content-Type' => 'text/plain'}, 'Bad Request'
    end
    events = LINE.client.parse_events_from(body)

    events.each do |event|
      Ally.logger.info( "="*39+">" )
      Ally.logger.debug( event.to_yaml ) # Debug the event data from LINE
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          # Parse the bot_command and bot_opts
          bot_cmd = BotCommand.new(client: :line, api_string: event.message['text'])
          # Fail early if we have an InvalidCommand (428: precondition required)
          unless bot_cmd.valid?
            Ally.logger.info( "<"+"="*39 )
            Ally.logger.info( " " )
            return [428, {}, []]
          end

          # Dynamically invoke the bot command requested by the user & respond
          LINE.client.reply_message(event['replyToken'], bot_cmd.excelsior!)
          Ally.logger.info( "<"+"="*39 )
          Ally.logger.info( " " )
        end
      end
    end

    "OK"
  end

end

use AllyBot
run lambda {|env| [404, {}, []]} # Return 404 if no other route matches
