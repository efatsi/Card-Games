class Player
  
  NAMES = %w(Fred Bill Henry Chris Annie Kyle Ryan Tom Ben Aren Fran Cindy)
  
  attr_accessor :name, :total_score, :round_score, :hand, :round_collection, :bid, :going_nil, :going_blind, :team
  
  def initialize
    @name = NAMES[rand(NAMES.length)]
    @total_score = 0
    @round_score = 0
    @hand = []
    @round_collection = []
    @bid = 0
    @going_nil = false
    @going_blind = false
    @team = nil
  end
    
  def only_has?(suit)
    self.hand.each do |card|
      return false if card.suit != suit
    end
    true
  end
  
end