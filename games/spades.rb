testing = true
# testing = false

if testing == true
  require './card_game.rb'   # for testing
else
  require '../card_game.rb'  # for running
end

class Spades < CardGame
  
  attr_accessor :team_1, :team_2, :dealer, :rounds, :tricks_played, :played, :lead_suit, :leader, :rounds_played 
  
  def initialize
    @size = 4  
    @players = []
    @team_1 = nil
    @team_2 = nil
    @winner = nil
    @deck = []
    @dealer = nil
    @rounds_played = 0
    @tricks_played = 0
    @played = []
    @lead_suit = nil
    @leader = nil
  end
  
  # resets 4 players, loads up a random dealer
  def load_players
    @players = []
    @size.times do
      new_player = Player.new
      @players << new_player unless @players.include?(new_player)
    end
    @team_1 = Team.new(@players[0], @players[2])
    @team_2 = Team.new(@players[1], @players[3])
    @players[0].team = @team_1
    @players[1].team = @team_2
    @players[2].team = @team_1
    @players[3].team = @team_2
    @dealer = @players[rand(@size)]
  end
  
  # resets the deck and played cards
  def load_deck
    @deck = Deck.new.cards
    @played = []
  end
  
  def pick_random_player
    @players[rand(@players.length)]
  end
  
  
  def play_game
    load_deck
    load_players
    while(!game_over?)
      @rounds_played += 1
      shuffle_cards
      play_round
      update_total_scores
      return_cards
      change_dealer
      check_for_winner
      @winner = @players.first if @rounds_played == 100
    end    
  end
  
  # deal cards, pay 13 tricks, 
  def play_round
    deal_cards
    make_bids
    13.times do
      play_trick
    end
  end
  
  def change_dealer
    current_index = @players.index(@dealer)
    @dealer = @players[(current_index+1) % @size]
  end
  
  def shuffle_cards
    2.times do
      new_deck = []
      @deck.each do |card|
        new_location = rand(new_deck.size+1)
        new_deck.insert(new_location, card)
      end
      @deck = new_deck
    end
  end
  
  # empty deck on the players one at a time
  def deal_cards
    if @deck.length == 52
      dealer_index = @players.index(@dealer)
      13.times do
        4.times do |i|
          player = @players[(dealer_index+i+1)%4]
          top = @deck.last
          player.hand << top
          @deck.delete(top)
          @leader = @players[0]
        end
      end
    end
  end
  
  def make_bids
    teams.each { |team| team.bid = 3 + rand(4) }
    if rand < 0.05
      @players[rand(4)].going_nil = true
    end
  end
  
  def play_trick
    leader_index = @players.index(@leader)
    4.times do |i|
      player = @players[(leader_index+i)%4]
      if player == @leader
        choice = pick_card(player)
        @lead_suit = choice.suit
      else
        choice = pick_card(player)
        while !choice.is_valid?(@lead_suit, player.hand)
          choice = pick_card(player)
        end
      end
      @played << choice
      player.hand.delete(choice)
    end
    recipient = determine_trick_winner(last_trick)
    recipient.round_collection += last_trick
    recipient.team.tricks_won += 1
  end  
  
  def determine_trick_winner(trick)
    max = trick.first
    leader_index = @players.index(@leader)
    4.times do |i|
      card = trick[(leader_index+i)%4]
      max = card if card.beats?(max)
    end
    @leader = @players[trick.index(max)] 
  end
  
  def update_round_scores
    teams.each do |team|
      if team.tricks_won > team.bid
        team.round_score += 10*team.bid
        team.bags += team.tricks_won - team.bid
      elsif team.tricks_won == team.bid
        team.round_score += 10*team.bid 
      else
        team.round_score -= 10*team.bid
      end
    end
    
    @players.each do |player|
      if player.going_nil
        player.team.round_score += (player.round_collection.empty? ? 100 : -100)
      end
      if player.going_blind
        player.team.round_score += (player.round_collection.empty? ? 200 : -200)
      end
    end
  end
  
  def update_total_scores
    update_round_scores
    teams.each do |team|
      team.total_score += team.round_score
      team.round_score = 0
    end
  end
  
  def return_cards
    @players.each do |player|
      player.hand.each do |card|
        @deck << card
      end
      player.round_collection.each do |card|
        @deck << card
      end
      player.hand = []
      player.round_collection = []
    end
    @leader = nil
    @tricks_played = 0
    teams.each { |team| team.bid = 0 }
  end
  
  def check_for_winner      
    winning_value = 0
    teams.each do |team|
      if team.total_score >= 500 && team.total_score > winning_value
        @winner = team
        winning_value = team.total_score
      end
    end
  end
  
  def last_trick
    @played[@played.length-4, 4]
  end

  def pick_card(player)
    player.hand[rand(player.hand.length)]
    # choice = nil
    # player.hand.each do |card|
    #   if card.suit == @lead_suit
    #     choice = card  
    #   end
    # end
    # choice = player.hand.last if choice.nil?
  end
  
  def teams
    [@team_1, @team_2]
  end
  
  def reset_scores
    teams.each do |team|
      team.total_score = 0
      team.bid = 0
      team.tricks_won = 0
      team.round_score = 0
      team.total_score = 0
    end
  end

end

class Card

  def beats?(card)
    return self.suit == :spade if self.suit != card.suit

    # if it's a face card
    if self.value.to_i == 0
      return true if card.value.to_i != 0

      case self.value
      when "A"
        ["K", "Q", "J"].include?(card.value)
      when "K"
        ["Q", "J"].include?(card.value)
      when "Q"
        ["J"].include?(card.value)
      else
        false
      end
      
    # if it isn't a face card
    else
      return false if card.value.to_i == 0
      self.value.to_i > card.value.to_i
    end
  end
  
  def is_valid?(lead_suit, hand)
    return true if self.suit == lead_suit
    hand.each do |card|
      return false if card.suit == lead_suit
    end
    true
  end
  
end

@spades = Spades.new
@spades.play_game
p @spades.winner
p @spades.rounds


