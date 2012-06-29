# require './card_game.rb'   # for testing
require '../card_game.rb'  # for running

class Hearts < CardGame
  
  attr_accessor :dealer, :rounds
  
  def initialize
    @size = 4  
    @players = []
    @winner = nil
    @deck = []
    @dealer = nil
    @rounds = 0
  end
  
  def load_players
    @players = []
    @size.times do
      new_player = Player.new
      @players << new_player unless @players.include?(new_player)
    end
    @dealer = @players[(rand*@size).floor]
  end
  
  def load_deck
    @deck = Deck.new.cards
  end
  
  def pick_random_player
    @players[rand(@players.length)]
  end
  
  def pick_highest_player
    max = 0
    @players.each do |player|
      if player.total_score > max
        @winner = player
        max = player.total_score
      end
    end  
    @winner    
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
  
  def play_round
    deal_cards
    13.times do
      play_hand
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
  
  def deal_cards
    if @deck.length == 52
      13.times do
        @players.each do |player|
          top = @deck.last
          player.hand << top
          @deck.delete(top)
        end
      end
    end
  end
  
  def play_hand
    played = []
    @players.each do |player|
      choice = player.hand.last
      played << choice
      player.hand.delete(choice)
    end
    recipient = pick_random_player
    played.each do |card|
      recipient.round_collection << card
    end
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
    
  end
  
  def played
    played_cards = []
    @players.each do |player|
      player.round_collection.each do |card|
        played_cards << card
      end
    end   
    played_cards
  end
  
end


@hearts = Hearts.new
@hearts.play_game
p @hearts.winner
p @hearts.rounds


