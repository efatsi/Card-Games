require 'spec_helper'

describe Game do

  before :all do
    @game = Game.new
    @hearts = Hearts.new
    @deck = Deck.new
    @hearts.load_players
  end

  describe "#new" do
    it "takes a game type and returns a game" do
      @game.should be_an_instance_of Game
    end
  end

  describe "#new_hearts" do
    it "should show that hearts has been initiated" do
      @hearts.should be_an_instance_of Hearts
    end
  end

  describe "#get_deck" do
    it "should return a new deck" do
      @deck.should be_an_instance_of Deck
    end
    it "should show that deck has 52 cards" do
      @deck.cards.length.should == 52
    end
    it "should show deck has all the cards" do
      (2..10).each do |i|
        @deck.cards.include?("#{i}C").should == true
        @deck.cards.include?("#{i}H").should == true      
        @deck.cards.include?("#{i}S").should == true
        @deck.cards.include?("#{i}D").should == true
      end
      ["J","Q","K","A"].each do |f|
        @deck.cards.include?("#{f}C").should == true
        @deck.cards.include?("#{f}H").should == true      
        @deck.cards.include?("#{f}S").should == true
        @deck.cards.include?("#{f}D").should == true
      end
    end
  end

  describe "#get_players" do
    it "should show required number of players" do
      @hearts.size.should == 4
    end
    it "should load in required number of players" do
      @hearts.players.length.should == @hearts.size
    end
  end

  describe "#play_games" do
    it "should 'play' a game of hearts and determine a winner" do
      @hearts.game_over?.should == false
      @hearts.play_game
      @hearts.game_over?.should == true
      @hearts.players.include?(@hearts.winner).should == true
    end
  end

  describe "#reset" do
    it "should reset the games with no players and no winner" do
      @hearts.reset
      @hearts.players.empty?.should == true
      @hearts.game_over?.should == false
    end
  end

end