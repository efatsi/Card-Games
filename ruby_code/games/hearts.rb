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

  def find_lowest_player
    min = 101
    winner = nil
    @players.each do |player|
      if player.total_score <= min
        winner = player
        min = player.total_score
      end
    end  
    winner    
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
      reset_round_values
      change_dealer
      check_for_winner
      @winner = @players.first if @rounds_played == 100
    end    
  end

  # deal cards, pay 13 tricks, 
  def play_round
    deal_cards
    # pass_cards(pass_direction) def pass_direction; %w(left right across none)[@rounds_played % 4]; end;
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
  end

  def reset_round_values
    @leader = nil
    @tricks_played = 0
  end

  def check_for_winner
    someone_lost = false
    @players.each do |player|
      someone_lost = true if player.total_score >= 100
    end
    if someone_lost
      @winner = find_lowest_player
    end

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

  def pass_cards(direction)
    return if direction == "none"
    cards_to_pass = [ [] , [] , [] , [] ]
    4.times do |i|
      3.times do
        cards_to_pass[i] << @players[i].hand[rand(@players[i].hand.length)]
      end
    end
    take_from_shift = case direction
    when "left"
      3
    when "across"
      2
    when "right"
      1
    end
    4.times do |i|
      @players[i].hand += cards_to_pass[(i + take_from_shift) % 4]
    end
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

  def reset_total_scores
    @players.each do |player|
      player.total_score = 0
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

  def is_valid?(lead_suit, hand)
    return true if self.suit == lead_suit
    hand.each do |card|
      return false if card.suit == lead_suit
    end
    true
  end

end

@hearts = Hearts.new
@hearts.play_game
p @hearts.winner
p @hearts.rounds


