require '../game.rb'

class Hearts < Game
  
  def initialize
    @players = []
    @winner = nil
    @size = 4
    set_player_number
  end
  
  def load_players
    @size.times do
      @players << Players.new
    end
  end
  
  def hearts_winner(players)
    @players[(rand*players.length).floor]
  end
  
  def play_game
    @winner = @players[(rand*@players.length).floor]
  end
  
end