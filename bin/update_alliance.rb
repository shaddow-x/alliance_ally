#!/usr/bin/env ruby
require_relative '../ally'

alliance_tag = ENV['ALLIANCE_TAG'] || "AABOT"
Ally.logger.info "Loading alliance: #{alliance_tag}"
alliance = Ally::Alliance.new(tag: alliance_tag)
Ally.logger.ap alliance
Ally.logger.ap alliance.ls_worksheets

Ally.logger.debug( puts " " )
Ally.logger.debug( ap "="*40 )
Ally.logger.debug( ap alliance )
Ally.logger.debug( ap "="*40 )

ap alliance.update_bgs
exit 0
