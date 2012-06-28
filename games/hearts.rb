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
  
  def pick_random_player
    @players[rand(@players.length)]
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
    update_total_scores
    return_cards
    @winner = pick_random_player
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
    dealt = []
    @players.each do |player|
      choice = player.hand.last
      dealt << choice
      player.hand.delete(choice)
    end
    recipient = pick_random_player
    dealt.each do |card|
      recipient.round_collection << card
    end
  end
  
  def update_round_scores
    @players.each do |player|
      player.round_score = 0
      player.round_collection.each do |card|
        if card.suit == :heart
          player.round_score += 1
        elsif card == "QS"
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
        deck << card
      end
      player.round_collection do |card|
        deck << card
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

class String
  def suit
    return :club if self[self.length-1] == "C"
    return :heart if self[self.length-1] == "H"
    return :spade if self[self.length-1] == "S"
    return :diamond if self[self.length-1] == "D"
  end
end


