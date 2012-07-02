testing = true
# testing = false

if testing == true
  require_relative "deck.rb"    # for tests
  require_relative "player.rb"
  require_relative "team.rb"
else
  require "../deck.rb"    # for running with a game
  require "../player.rb"
  require "../team.rb"
end

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


