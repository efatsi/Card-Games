require_relative './deck'

class Game
  
  attr_accessor :type
  
  def initialize(type)
    @type = type
  end
  
end