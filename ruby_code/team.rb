class Team
  
  attr_accessor :players, :bid, :bags, :tricks_won, :round_score, :total_score
  
  def initialize(player_1, player_2)
    @players = [player_1, player_2]
    @bid = 0
    @bags = 0
    @tricks_won = 0
    @round_score = 0
    @total_score = 0
  end
    
end