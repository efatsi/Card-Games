class Player
  
  NAMES = %w(Fred Bill Henry Chris Annie Kyle Ryan Tom Ben Aren Fran Cindy)
  
  attr_accessor :name, :total_score, :round_score, :hand, :round_collection
  
  def initialize
    @name = NAMES[(rand*NAMES.length).floor]
    @total_score = 0
    @round_score = 0
    @hand = []
    @round_collection = []
  end
    
end