class Player
  
  NAMES = %w(Fred Bill Henry Chris Annie Kyle Ryan Tom Ben Aren Fran Cindy)
  
  attr_accessor :name, :score, :hand
  
  def initialize
    @name = NAMES[(rand*NAMES.length).floor]
    @score = 0
    @hand = []
  end
    
end