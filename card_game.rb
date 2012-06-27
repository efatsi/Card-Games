require_relative "deck.rb"    # for tests
require_relative "player.rb"
# require "../deck.rb"    # for running with a game
# require "../player.rb"

class CardGame
  
  attr_accessor :size, :players, :winner, :deck
  
  def game_over?
    !@winner.nil?
  end
  
  def reset
    @winner = nil
    @players = []
  end 
  
end


