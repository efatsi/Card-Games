# require_relative "card.rb"    # for tests
require "../card.rb" # run with game

class Deck
  
  attr_accessor :cards
  
  def initialize
    @cards = []
    
    [:club, :heart, :spade, :diamond].each do |suit|
      (2..10).each do |value|
        @cards << Card.new(suit, value.to_s)      
      end
      ["J", "Q", "K", "A"].each do |value|
        @cards << Card.new(suit, value.to_s)
      end
    end
      
  end
  
end
