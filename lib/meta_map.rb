require_relative '../ally'
require 'json'

module Ally
  class MetaMap
    include Ally

    ###########################
    # MAP COORDINATES BY TYPE #
    ###########################

    SUPPORTED_MAPS = [:rondar]

    RONDAR_MAP7_T1 = [[542,116],[542,181],[85,206], [85,271],[177,456],[853,374], [853,440],[395,640],[395,706], [177,517]].freeze
    RONDAR_MAP7_T2 = [[613,114],[613,173],[95,259], [95,319],[315,451],[318,510], [462,651],[462,713],[852,380], [855,438]].freeze
    RONDAR_MAP7_T3 = [[641,100],[641,161],[79,221], [80,281],[839,318],[839,379], [390,661],[390,719],[202,460], [200,519]].freeze

    def self.rondar(map, tier)
      self.const_get("RONDAR_MAP#{map.to_s}_T#{tier.to_s}")
    end
  end
end