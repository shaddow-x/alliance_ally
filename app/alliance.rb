require_relative '../ally'
require 'active_support'
require 'active_support/core_ext/string'

module Ally
  class Alliance
    extend Ally
    attr_accessor :name, :tag, :leader_id, :drive_sheet, :player_sheet, :bg_sheet, :cloudinary_auth, :family
    class InvalidParams < ArgumentError; end

    def initialize(tag: nil, name: nil, leader_id: nil)
      raise InvalidParams, 'Missing alliance tag' if tag.nil? or tag.empty?
      @tag, @name, @leader_id = tag, name, leader_id
      Ally.logger.debug("@tag: #{@tag}, @name: #{@name}, @leader_id: #{@leader_id}")
      @@google_client = Ally::GoogleClient.new.session
      @drive_sheet = @@google_client.spreadsheet_by_title("AllianceAlly::#{@tag}")
      @player_sheet = @drive_sheet.worksheet_by_title("#{@tag}::Main")
      @bg_sheet = @drive_sheet.worksheet_by_title("Battlegroups")
      @@cloudinary_auth = Ally::CloudinaryClient.new.auth
      @family = init_family # Initialize the Alliance Family value, if parseable
      # Log the new instance of an alliance
      Ally.logger.ap( self )
    end

    # Some of these can be best-guessed
    # Others are mandated
    # Some families are impossible to guess (Ohana has no tag rules, S17 has
    # some with and some without)
    # Families I'm still looking for patterns from: GOM, Resistance, LOKI, ISO
    FAMILY_MATCHERS = {
      "AGT•": "AGT",
      "S17": "S17A",
      "XMN": "XMN",
      "HC•": "HC",
      "ĞӨΜ": "GOM",
      "TVΛ": "TVA",
      "FAM": "BOB",
      "ISO8": "ISO8",
    }

    # NOTE: Family Shorthand Aliases
    # ohana
    # s17a
    # resist

    # Identify regex for common MCOC Family tags and assign to @family
    def init_family
      FAMILY_MATCHERS.each do |family_matcher, family|
        @family = family if @tag.upcase.include?(family_matcher.upcase.to_s)
        break unless @family.nil?
      end
      @family
    end

    # Return the current players from the Google sheet in real time
    def players
      Ally.logger.debug(".players called, resetting players to []")
      @player_sheet.reload # Ensure we have the latest data
      players = []

      @player_sheet.rows.each_with_index do |row, index|
        break if index > 31 # Stop after we capture all 30 players data
        Ally.logger.debug("Index row: #{index}")
        next if index == 0 # Skip the column header row
        next if row[2].nil? || row[2].empty? # Skip if there is no player ID

        player_id = row[2].to_str.parameterize.underscore
        player = Ally::Player.new(
          str_id: player_id,
          alliance: @tag,
          bg: row[1],
          name: row[2],
          prestige: row[3],
          timezone: row[4],
          notes: row[5],
          path_likes: row[6],
          path_dislikes: row[7],
        )
        Ally.logger.debug("Inserting player: #{player.inspect}")
        players << player
      end

      Ally.logger.debug("Returning players: #{players}")
      players
    end

    def ls_worksheets
      # Output worksheet titles
      puts "="*80
      puts "# WORKSHEETS:" + " "*64+"#"
      puts "="*80
      ap @drive_sheet.worksheets.map(&:title)
    end

    ##################
    # BG Assignments #
    ##################

    # Reset the Battlegroups Worksheet Data
    def clear_bgs
      for row in 1..39
        # Set the columns for each row to empty strings
        @bg_sheet["A#{row}"] = ""
        @bg_sheet["B#{row}"] = ""
        @bg_sheet["C#{row}"] = ""
        @bg_sheet["D#{row}"] = ""
        @bg_sheet["E#{row}"] = ""
      end

      @bg_sheet.save
    end

    def update_bgs
      # Purge the Battlegroups worksheet
      clear_bgs
      # Refresh the worksheet to ensure we have current data
      @bg_sheet.reload

      # Pull the real-time list of players (cached instead of 3x calls)
      current_players = players

      # Create initial rows with automated data warning banner!
      @bg_sheet["A1"] = "WARNING, THIS DATA IS AUTOMATICALLY GENERATED, DO NOT EDIT!!!"
      @bg_sheet["A2"] = "BATTLE GROUP ASSIGNMENTS"
      @bg_sheet["A39"] = "WARNING, THIS DATA IS AUTOMATICALLY GENERATED, DO NOT EDIT!!!"

      # Populate BG data
      for bg in 1..3
        current_players.select{|p| p.bg == bg}.each_with_index do |player, index|
          Ally.logger.debug( "BG: #{bg}, index: #{index}" )
          Ally.logger.debug( player )
          case bg
          when 1
            row_base = 4
          when 2
            row_base = 16
          when 3
            row_base = 28
          end
          row = row_base + index

          # Generate header before each BG's players:
          if index == 0
            @bg_sheet["A#{row_base-1}"] = "Battlegroup #{bg}"
            @bg_sheet["B#{row_base-1}"] = "TZ"
            @bg_sheet["C#{row_base-1}"] = "Path Likes"
            @bg_sheet["D#{row_base-1}"] = "Path Dislikes"
            @bg_sheet["E#{row_base-1}"] = "Notes"
          end

          # Columns: A=player, B=TZ, C=path_likes, D=path_dislikes, E=notes
          @bg_sheet["A#{row}"] = player.name
          @bg_sheet["B#{row}"] = player.timezone
          @bg_sheet["C#{row}"] = player.path_likes
          @bg_sheet["D#{row}"] = player.path_dislikes
          @bg_sheet["E#{row}"] = player.notes
        end
      end

      # Save after editing the BG worksheet
      @bg_sheet.save
      "Battlegroups Updated Successfully"
    end

    ####################
    # Path Assignments #
    ####################

    def get_path_assignments(variant:, bg:, tier:)
      # All params should be passed in as integrers
      Ally.logger.debug("variant: #{variant}")
      Ally.logger.debug("bg: #{bg}")
      Ally.logger.debug("tier: #{tier}")

      map_sheet = @drive_sheet.worksheet_by_title("V#{variant} Paths")
      bg_col = { "1": "C", "2": "D", "3": "E" }
      tier_base_row = { "1": 2, "2": 13, "3": 24 }

      paths_hash = {}
      unless tier == "all"
        for index in 1..10
          cell = "#{bg_col[bg.to_s.to_sym]}#{tier_base_row[tier.to_s.to_sym]+index}"
          Ally.logger.debug("Retreiving cell: #{cell}")
          player_for_path = map_sheet[cell]
          paths_hash[index.to_s.to_sym] = player_for_path
        end
      end

      paths_hash
    end

    def create_map_tier(variant:, bg:, tier:)
      # All params should be passed in as integrers
      Ally.logger.debug("variant: #{variant}")
      Ally.logger.debug("bg: #{bg}")
      Ally.logger.debug("tier: #{tier}")

      player_paths = get_path_assignments(variant: variant, bg: bg, tier: tier)
      player_paths
    end

  end
end
