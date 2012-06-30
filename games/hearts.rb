testing = true
# testing = false

if testing == true
  require './card_game.rb'   # for testing
else
  require '../card_game.rb'  # for running
end

class Hearts < CardGame
  
  attr_accessor :dealer, :rounds, :tricks_played, :played, :lead_suit, :leader 
  
  def initialize
    @size = 4  
    @players = []
    @winner = nil
    @deck = []
    @dealer = nil
    @rounds = 0
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
  
  def pick_highest_player
    max = 0
    highest = nil
    @players.each do |player|
      if player.total_score >= max
        highest = player
        max = player.total_score
      end
    end  
    highest    
  end
  
  def play_game
    load_deck
    load_players
    while(!game_over?)
      @rounds += 1
      shuffle_cards
      play_round
      update_total_scores
      return_cards
      if (rand < 0.3)
        @winner = pick_highest_player
      end
      change_dealer
    end    
  end
  
  # deal cards, pay 13 tricks, 
  def play_round
    deal_cards
    13.times do
      play_trick
      determine_trick_winner(last_trick)
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
          @leader = two_of_clubs_owner if @tricks_played = 0
        end
      end
    end
  end
  
  def play_trick
    leader_index = @players.index(@leader)
    4.times do |i|
      player = @players[(leader_index+i)%4]
      if player == @leader
        choice = player.hand.last
        @lead_suit = choice.suit
      else
        choice = nil
        player.hand.each do |card|
          if card.suit == @lead_suit
            choice = card  
          end
        end
        choice = player.hand.last if choice.nil?
      end
      @played << choice
      player.hand.delete(choice)
    end
    recipient = determine_trick_winner(last_trick)
    recipient.round_collection += last_trick
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
    @players.each do |player|
      player.round_score = 0
      player.round_collection.each do |card|
        if card.suit == :heart
          player.round_score += 1
        elsif card.value == "Q" && card.suit == :spade
          player.round_score += 13
        end
      end  
    end
  end
  
  def update_total_scores
    update_round_scores
    @players.each do |player|
      if player.round_score == 26
        @players.each { |p| p.total_score += 26 unless p == player }
      else
        player.total_score += player.round_score
      end
    end
  end
  
  def reset_total_scores
    @players.each do |player|
      player.total_score = 0
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
  end
  
  def last_trick
    @played[@played.length-4, 4]
  end
  
  def two_of_clubs_owner
    @players.each do |player|
      player.hand.each do |card|
        if card.suit == :club && card.value = "2"
          return player
        end
      end
    end
  end
  
end

class Card
  
  def beats?(card)
    return false if self.suit != card.suit
    
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
  
end

@hearts = Hearts.new
@hearts.play_game
p @hearts.winner
p @hearts.rounds


