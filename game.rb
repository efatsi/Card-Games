require './deck.rb'
require './player.rb'

class Game
  
  attr_accessor :size, :players, :winner
  
  def game_over?
    !@winner.nil?
  end
  
  def reset
    @winner = nil
    @players = []
  end 
end


class Hearts < Game
  
  def initialize
    @players = []
    @winner = nil
    @size = 4
  end
  
  def load_players
    @size.times do
      @players << Player.new
    end
  end
  
  def hearts_winner(players)
    @players[(rand*players.length).floor]
  end
  
  def play_game
    @winner = @players[(rand*@players.length).floor]
  end
  
end

