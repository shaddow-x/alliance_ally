require_relative '../ally'

class Ally::Player
  extend Ally
  @@instance_collector = []

  attr_accessor :str_id, :alliance, :name, :prestige, :timezone, :bg, :notes, :path_likes, :path_dislikes

  def initialize(str_id: nil, alliance: nil, name: nil, prestige: nil, timezone: nil, bg: nil, notes: nil, path_likes: nil, path_dislikes: nil)
    @@instance_collector << self
    @str_id, @alliance, @name, @prestige, @timezone, @bg, @notes, @path_likes, @path_dislikes =
      str_id, alliance, name, prestige.to_i, timezone, bg.to_i, notes, path_likes, path_dislikes
    Ally.logger.debug( self.inspect )
  end

  def self.all
    @@instance_collector
  end

end
