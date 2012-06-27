require './card_game.rb'   # for testing
# require '../card_game.rb'  # for running

class Hearts < CardGame
  
  attr_accessor :dealer
  
  def initialize
    @size = 4  
    @players = []
    @winner = nil
    @deck = []
    @dealer = nil
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
  
  def hearts_winner(players)
    @players[(rand*players.length).floor]
  end
  
  def play_game
    play_round unless game_over?    
  end
  
  def play_round
    reset_dealer
    shuffle_cards
    deal_cards
    13.times do
      play_hand
    end
    @winner = hearts_winner(@players)
  end
  
  def reset_dealer
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
    13.times do
      @players.each do |player|
        top = @deck.last
        player.hand << top
        @deck.delete(top)
      end
    end
  end
  
  def play_hand
    @players.each do |player|
      choice = player.hand.last
      @deck << choice
      player.hand.delete(choice)
    end
  end
  
  
end


