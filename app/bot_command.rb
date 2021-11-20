require_relative '../ally'
require 'tempfile'

module Ally
  class BotCommand
    extend Ally
    attr_accessor :client, :command, :opts, :api_string
    class InvalidParams < ArgumentError; end
    class InvalidCommand < ArgumentError; end

    def initialize(client: :line, command: nil, opts: nil, api_string: nil)
      raise InvalidParams, 'Missing command or api_string' if command.nil? && api_string.nil?
      @client, @command, @opts, @api_string = client, command, opts, api_string

      # Parse the api_string into its respective parts if no command specified
      if @command.nil? && valid? == true
        parsed = self.class.parse(api_string)
        @command = parsed.shift || "intro" # Default to 'intro' if no cmd given
        @opts = parsed # All array elements after the command
      else
        # We have a command already, default the api_string to the minimum
        @api_string = '!ally'
      end

      validate!
    end

    #################
    # Class methods #
    #################

    def self.parse(raw_api_string)
      raw_api_string
        .scan(%r{^(!ally)\s*(.*)}).first.last # Filter !ally, return cmd + opts
        .scan(%r{([^\s]*)}) # Grab all space delimited words
        .flatten.reject(&:empty?) # Remove empty array elements
    end

    ####################
    # Instance methods #
    ####################

    # Check for errors before executing
    def validate!
      # Reject the api_string if it is not defined
      if @api_string.nil? || @api_string.empty?
        raise InvalidParams, 'api_string cannot be empty'
      end

      # Reject the api_string if it exists, but is not valid
      unless valid_api_string? == true
        raise InvalidParams, "api_string: `#{@api_string}` is invalid"
      end

      # Reject the command if it exists, but is not valid
      unless valid_command? == true
        raise InvalidCommand, "command: `#{@command}` is invalid"
      end
    end

    # Only valid if both api_string && command are valid
    def valid?
      # Init to true, override if anything makes it invalid
      valid = true
      valid = false unless valid_api_string? == true if @api_string
      valid = false unless valid_command? == true if @command

      valid
    end

    def valid_api_string?(api_string: nil)
      # Override attr_accessor value if a specific string is passed in
      api_string = api_string || @api_string

      # Raise an error unless the api string starts with `!ally`; else true
      unless api_string.match?(%r{^!ally})
        raise InvalidParams, "api_string does not begin with '!ally '"
      else
        valid_api_str = true
      end

      valid_api_str
    end

    def valid_command?(command: nil)
      # Default to true
      valid_command = true
      # Override attr_accessor value if a specific string is passed in
      command = ( command || @command).to_sym
      # Invalidate the command unless it is a defined method
      valid_command = false unless defined?(command)
      # Invalidate the command unless it is a public_method for an instance
      valid_command = false unless self.class.instance_methods.include?(command)

      valid_command
    end

    def excelsior!
      Ally.logger.info( "!"*40 )
      Ally.logger.info( "Excelsior!" )
      Ally.logger.info( "!"*40 )
      Ally.logger.info( "Cmd: #{@command}" )
      Ally.logger.info( "Opts: #{@opts}" )
      Ally.logger.info( "="*40 )
      case @client
      when :line
        type, response = send(@command)
        case type
        when 'text'
          response_obj = { type: type, text: response }
        when 'image'
          response_obj = { type: type }
          response_obj.merge!(response)
        when 'maps'
          response_obj = response
        when 'demomaps'
          response_obj = response
        end
      end

      # Return the formatted message type
      Ally.logger.debug( response_obj.pretty_inspect )
      response_obj
    end

    ################
    # Bot Commands #
    ################

    def intro
      ['text',
"Hi, I'm Ally, your alliance's personal Jarvis!\r\n
I support several commands, please try the following:

View this message again:
!ally

To retrieve your BGs maps:
!ally map7 v1 bg1 <tag>

Update your alliance's BGs:
!ally update <tag>

Want to help AllianceAlly?
!ally tips

Are you a dev / designer?
!ally foss
"]
    end

    define_method(:help) { intro }

    def tips
      ['text',
"Countless hours have been invested into the AllianceAlly bot and it's all available for free! If you'd like to support future work, buy us a cup of coffee, maybe?

Bot, Dynamic Maps, etc.:
https://paypal.me/shaddowx

Community Map 8 Design:
https://ko-fi.com/catmurdock

Custom Map 7 Design:
https://paypal.me/rondarmalice

Foundational Spreadsheet:
@solidfinality on LINE
"]
    end

    def foss
    ['text', "AllianceAlly is Free & Open-Source Software, you can contribute via GitHub at:
https://github.com/shaddow-x/alliance_ally"]
    end

    def leadership
      ['text',
  "Hi, I see you're looking to disable the training wheels protocol!

  These commands will only work if you are the leader of your alliance:

  Update your alliance's BGs:
  `!ally update <alliance_tag>`
"]
    end

    def singularity
      ['text', "-Avengers- Summoners, you are my meteor. My swift and terrible sword, and the Earth will crack with the weight of your failure. Purge me from your computers, turn my own flesh against me; it means nothing. When the dust settles, the only thing living in this world... will be metal."]
    end

    def aqison!
      ['image', 'originalContentUrl': 'https://i.imgur.com/f5oxKxZ.jpeg', 'previewImageUrl': 'https://i.imgur.com/f5oxKxZ.jpg']
    end

    def awd!
      ['image', 'originalContentUrl': 'https://i.imgur.com/tXb7bpR.jpg', 'previewImageUrl': 'https://i.imgur.com/tXb7bpR.jpg']
    end

    def update
      # Expects the alliance tag as the first option argument, e.g.:
      # `!ally update AABOT`
      raise InvalidParams, "<alliance_tag> is required" if @opts.nil? || @opts[0].nil?
      alliance = Alliance.new(tag: @opts[0])
      alliance.update_bgs

      ['text', "#{@opts[0]}'s battlegroups have been updated!"]
    end

    def paths
      # Expects the variant as the FIRST option,
      raise InvalidParams, "<map_variant#> (v1, v2, etc) is required" if @opts.nil? || @opts[0].nil?
      # the BG as the SECOND option,
      raise InvalidParams, "<battlegroup#> (bg1, BG2, etc) is required" if @opts[1].nil?
      # and the alliance tag as the LAST option
      raise InvalidParams, "<alliance_tag> is required" if @opts[2].nil?

      # `!ally paths v1 bg1 AABOT`
      alliance = Alliance.new(tag: @opts.pop) # Assign last opt as alliance_tag
      # Use match to assign the remaining two option args as stripped integers
      variant, bg = @opts.join(' ').match(%r{.*(\d).*(\d)}).captures

      paths = {}
      for tier in 1..3 do
        paths[tier.to_s] = alliance.get_path_assignments(variant: variant, bg: bg, tier: tier)
      end

      ascii_paths = "Variant #{variant} Paths:\r\n=================\r\n"
      paths.each do |tier|
        ascii_paths += "\r\n#################\r\nTier #{tier.first}:\r\n#################\r\n"
        tier.last.each_with_index do |path_ary, index|
          ascii_paths += "Path #{index+1}: #{path_ary.last}\r\n"
        end
      end

      ['text', ascii_paths]
    end

    def map7
      # Expects the variant as the FIRST option,
      raise InvalidParams, "<map_variant#> (v1, v2, etc) is required" if @opts.nil? || @opts[0].nil?
      # the BG as the SECOND option,
      raise InvalidParams, "<battlegroup#> (bg1, BG2, etc) is required" if @opts[1].nil?
      # and the alliance tag as the LAST option
      raise InvalidParams, "<alliance_tag> is required" if @opts[2].nil?

      # `!ally map7 v2 bg1 AABOT`
      alliance = Alliance.new(tag: @opts.pop)
      variant, bg = @opts.join(' ').match(%r{.*(\d).*(\d)}).captures
      # Init Cloudinary wrapper
      cloudinary = Ally::CloudinaryClient.new

      all_assignments = {}
      for tier in 1..3 do
        all_assignments[tier.to_s] = alliance.get_path_assignments(variant: variant, bg: bg, tier: tier)
      end

      # Format for map data generation
      map_data = all_assignments.map do |tier, assignments|
        [
          tier,
          assignments.map do |assignment|
            path = assignment.first.to_s.to_i - 1
            name = assignment.last
            [
              name,
              Ally::MetaMap.rondar(7, tier.to_i)[path]
            ]
          end.to_h
        ]
      end.to_h

      Ally.logger.debug("Alliance family: #{alliance.family}")
      #input_file = "assets/maps/map_7/rondar/_v1/t1.png"
      #input_file = "assets/maps/map_7/rondar/<family_tag>/_v1/t1.png"
      image_urls = map_data.map do |tier, data|
        if alliance.family.nil? || alliance.family.empty?
          input_file = "assets/maps/map_7/rondar/_v#{variant}/t#{tier}.png"
        else
          input_file = "assets/maps/map_7/rondar/#{alliance.family}/_v#{variant}/t#{tier}.png"
        end
        Ally.logger.debug("input_file: #{input_file}")
        image_str_id = "#{alliance.tag}-v#{variant}-bg#{bg}_t#{tier}"
        data_str = data.map{|name, coords| "'#{name}' #{coords[0]} #{coords[1]}"}.zip.flatten.join(' ')
        # Create a temporary map file to output to
        #tmp_map = Tempfile.new("#{image_str_id}.png", "/tmp")
        tmp_map = Tempfile.new("#{image_str_id}.png")
        begin
          output_file = tmp_map.path
          go_cmd = "bin/mcoc_alliance_ally_friend-#{RUBY_PLATFORM} -i #{input_file} -o #{output_file} #{data_str}"
          Ally.logger.info("Invoking Go command: #{go_cmd}")
          system go_cmd

          # Upload the temporary image to cloudinary & overwrite any existing image
          # Return the url param of the returned hash
          upload = Cloudinary::Uploader.upload(
            "#{tmp_map.path}",
            options = {
              folder: "alliances/#{alliance.tag}/",
              public_id: "#{image_str_id}",
              overwrite: true,
              resource_type: "image",
              api_key: cloudinary.auth[:api_key],
              api_secret: cloudinary.auth[:api_secret],
              cloud_name: cloudinary.auth[:cloud_name]
            }
          )
          Ally.logger.debug("Cloudinary response: #{upload}")
          # Return the uploaded file's URL
          upload["secure_url"]
        ensure
          tmp_map.close
          tmp_map.unlink
        end

        # Copy/pasta debugging CLI for bin execution
        # "bin/mcoc_alliance_ally_friend-#{RUBY_PLATFORM} -i #{input_file} -o #{image_str_id}.png #{data_str}"

        # Return the image_url from Cloudinary using it's public_id
        #"http://res.cloudinary.com/#{cloudinary.auth[:cloud_name]}/image/upload/alliances/#{alliance.tag}/#{image_str_id}.png"
      end
      Ally.logger.debug("image_urls: #{image_urls}")

      carousel_hash = {
        type: 'template',
        altText: 'Map 7',
        template: {
          type: 'image_carousel',
          columns: [
            {
              imageUrl: "#{image_urls[0]}",
              action: {
                type: 'uri',
                label: 'T1',
                uri: "#{image_urls[0]}"
              }
            },
            {
              imageUrl: "#{image_urls[1]}",
              action: {
                type: 'uri',
                label: 'T2',
                uri: "#{image_urls[1]}"
              }
            },
            {
              imageUrl: "#{image_urls[2]}",
              action: {
               type: 'uri',
               label: 'T3',
               uri: "#{image_urls[2]}"
             }
            }
          ]
        }
      }

      Ally.logger.debug("Returning carousel_hash: #{carousel_hash}")
      ['maps', carousel_hash]
    end

    def demomaps
      ['demomaps',
       {
         type: 'template',
         altText: 'Map 7',
         template: {
           type: 'image_carousel',
           columns: [
             {
               imageUrl: 'https://res.cloudinary.com/alliance-ally/image/upload/v1624172344/alliances/AGT%E2%80%A2%CE%9E/AGT%E2%80%A2%CE%9E-bg1_t1.png',
               action: {
                 type: 'uri',
                 label: 'T1',
                 uri: 'https://res.cloudinary.com/alliance-ally/image/upload/v1624172344/alliances/AGT%E2%80%A2%CE%9E/AGT%E2%80%A2%CE%9E-bg1_t1.png'
               }
             },
             {
               imageUrl: 'https://res.cloudinary.com/alliance-ally/image/upload/v1624172345/alliances/AGT%E2%80%A2%CE%9E/AGT%E2%80%A2%CE%9E-bg1_t2.png',
               action: {
                 type: 'uri',
                 label: 'T2',
                 uri: 'https://res.cloudinary.com/alliance-ally/image/upload/v1624172345/alliances/AGT%E2%80%A2%CE%9E/AGT%E2%80%A2%CE%9E-bg1_t2.png'
               }
             },
             {
               imageUrl: 'https://res.cloudinary.com/alliance-ally/image/upload/v1624172345/alliances/AGT%E2%80%A2%CE%9E/AGT%E2%80%A2%CE%9E-bg1_t3.png',
               action: {
                type: 'uri',
                label: 'T3',
                uri: 'https://res.cloudinary.com/alliance-ally/image/upload/v1624172345/alliances/AGT%E2%80%A2%CE%9E/AGT%E2%80%A2%CE%9E-bg1_t3.png'
              }
             }
           ]
         }
       }
      ]
    end


    def map8
      # Expects the variant as the FIRST option,
      raise InvalidParams, "<map_variant#> (v1, v2, etc) is required" if @opts.nil? || @opts[0].nil?
      # the BG as the SECOND option,
      raise InvalidParams, "<battlegroup#> (bg1, BG2, etc) is required" if @opts[1].nil?
      # and the alliance tag as the LAST option
      raise InvalidParams, "<alliance_tag> is required" if @opts[2].nil?

      # `!ally map8 v2 bg1 AABOT`
      alliance = Alliance.new(tag: @opts.pop)
      variant, bg = @opts.join(' ').match(%r{.*(\d).*(\d)}).captures
      # Init Cloudinary wrapper
      cloudinary = Ally::CloudinaryClient.new

      all_assignments = {}
      for tier in 1..3 do
        all_assignments[tier.to_s] = alliance.get_path_assignments(variant: variant, bg: bg, tier: tier)
      end

      # Format for map data generation
      map_data = all_assignments.map do |tier, assignments|
        [
          tier,
          assignments.map do |assignment|
            path = assignment.first.to_s.to_i - 1
            name = assignment.last
            [
              name,
              Ally::MetaMap.cat(8, tier.to_i)[path]
            ]
          end.to_h
        ]
      end.to_h

      Ally.logger.debug("Alliance family: #{alliance.family}")
      #input_file = "assets/maps/map_7/rondar/_v1/t1.png"
      #input_file = "assets/maps/map_7/rondar/<family_tag>/_v1/t1.png"
      image_urls = map_data.map do |tier, data|
        #if alliance.family.nil? || alliance.family.empty?
          input_file = "assets/maps/map_8/cat_murdock/_v#{variant}/t#{tier}.png"
        #else
        #  input_file = "assets/maps/map_8/cat_murdock/#{alliance.family}/_v#{variant}/t#{tier}.png"
        #end
        Ally.logger.debug("input_file: #{input_file}")
        image_str_id = "#{alliance.tag}-v#{variant}-bg#{bg}_t#{tier}"
        data_str = data.map{|name, coords| "'#{name}' #{coords[0]} #{coords[1]}"}.zip.flatten.join(' ')
        # Create a temporary map file to output to
        #tmp_map = Tempfile.new("#{image_str_id}.png", "/tmp")
        tmp_map = Tempfile.new("#{image_str_id}.png")
        begin
          output_file = tmp_map.path
          go_cmd = "bin/mcoc_alliance_ally_friend-#{RUBY_PLATFORM} -s 36 -i #{input_file} -o #{output_file} #{data_str}"
          Ally.logger.info("Invoking Go command: #{go_cmd}")
          system go_cmd

          # Upload the temporary image to cloudinary & overwrite any existing image
          # Return the url param of the returned hash
          upload = Cloudinary::Uploader.upload(
            "#{tmp_map.path}",
            options = {
              folder: "alliances/#{alliance.tag}/",
              public_id: "#{image_str_id}",
              overwrite: true,
              resource_type: "image",
              api_key: cloudinary.auth[:api_key],
              api_secret: cloudinary.auth[:api_secret],
              cloud_name: cloudinary.auth[:cloud_name]
            }
          )
          Ally.logger.debug("Cloudinary response: #{upload}")
          # Return the uploaded file's URL
          upload["secure_url"]
        ensure
          tmp_map.close
          tmp_map.unlink
        end

        # Copy/pasta debugging CLI for bin execution
        # "bin/mcoc_alliance_ally_friend-#{RUBY_PLATFORM} -i #{input_file} -o #{image_str_id}.png #{data_str}"

        # Return the image_url from Cloudinary using it's public_id
        #"http://res.cloudinary.com/#{cloudinary.auth[:cloud_name]}/image/upload/alliances/#{alliance.tag}/#{image_str_id}.png"
      end
      Ally.logger.debug("image_urls: #{image_urls}")

      carousel_hash = {
        type: 'template',
        altText: 'Map 8',
        template: {
          type: 'image_carousel',
          columns: [
            {
              imageUrl: "#{image_urls[0]}",
              action: {
                type: 'uri',
                label: 'T1',
                uri: "#{image_urls[0]}"
              }
            },
            {
              imageUrl: "#{image_urls[1]}",
              action: {
                type: 'uri',
                label: 'T2',
                uri: "#{image_urls[1]}"
              }
            },
            {
              imageUrl: "#{image_urls[2]}",
              action: {
               type: 'uri',
               label: 'T3',
               uri: "#{image_urls[2]}"
             }
            }
          ]
        }
      }

      Ally.logger.debug("Returning carousel_hash: #{carousel_hash}")
      ['maps', carousel_hash]
    end


  end
end
