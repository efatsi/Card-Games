require 'spec_helper'

describe Hearts do

  before :all do
    @hearts = Hearts.new
    @deck = @hearts.load_deck
    @hearts.load_players
  end

  describe "#new_hearts" do
    it "should show that hearts has been initiated" do
      @hearts.should be_an_instance_of Hearts
    end
  end

  describe "#get_deck" do
    it "should return a new array" do
      @deck.should be_an_instance_of Array
    end
    it "should show that deck has 52 cards" do
      @deck.length.should == 52
    end
    it "should show deck has all the cards" do
      (2..10).each do |i|
        @deck.include?("#{i}C").should == true
        @deck.include?("#{i}H").should == true      
        @deck.include?("#{i}S").should == true
        @deck.include?("#{i}D").should == true
      end
      ["J","Q","K","A"].each do |f|
        @deck.include?("#{f}C").should == true
        @deck.include?("#{f}H").should == true      
        @deck.include?("#{f}S").should == true
        @deck.include?("#{f}D").should == true
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
    it "should have picked a dealer" do
      @hearts.dealer.should_not be_nil
      @hearts.players.include?(@hearts.dealer).should == true
    end
  end

  describe "#game_play" do
  
    it "reset dealer should choose next player in @players array" do
      old_dealer_index = @hearts.players.index(@hearts.dealer)
      @hearts.reset_dealer
      new_dealer_index = @hearts.players.index(@hearts.dealer)
      new_dealer_index.should == (old_dealer_index + 1) % 4
    end
    
    it "dealer should be the same after 4 dealer changes" do
      current_dealer = @hearts.dealer
      2.times do
        @hearts.reset_dealer
      end
      # dealer is actually changing
      current_dealer.should_not == @hearts.dealer
      2.times do
        @hearts.reset_dealer
      end
      current_dealer.should == @hearts.dealer
    end
    
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