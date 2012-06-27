require 'spec_helper'

describe Hearts do

  before :all do
    @hearts = Hearts.new
    @hearts.load_deck
    @hearts.load_players
  end

  describe "#new_hearts" do
    it "should show that hearts has been initiated" do
      @hearts.should be_an_instance_of Hearts
    end
  end

  describe "#get_deck" do
    it "should return a new array" do
      @hearts.deck.should be_an_instance_of Array
    end
    it "should show that deck has 52 cards" do
      @hearts.deck.length.should == 52
    end
    it "should show deck has all the cards" do
      (2..10).each do |i|
        @hearts.deck.include?("#{i}C").should == true
        @hearts.deck.include?("#{i}H").should == true      
        @hearts.deck.include?("#{i}S").should == true
        @hearts.deck.include?("#{i}D").should == true
      end
      ["J","Q","K","A"].each do |f|
        @hearts.deck.include?("#{f}C").should == true
        @hearts.deck.include?("#{f}H").should == true      
        @hearts.deck.include?("#{f}S").should == true
        @hearts.deck.include?("#{f}D").should == true
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
    
    context "#dealer_assignment" do
      
      it "reset dealer should choose next player in @players array" do
        old_dealer_index = @hearts.players.index(@hearts.dealer)
        @hearts.reset_dealer
        new_dealer_index = @hearts.players.index(@hearts.dealer)
        new_dealer_index.should == (old_dealer_index + 1) % 4
      end
    
      it "dealer should be the same after 4 dealer changes" do
        current_dealer = @hearts.dealer
        4.times do
          @hearts.reset_dealer
        end
        current_dealer.should == @hearts.dealer
      end
      
    end
    
    context "#shuffling" do
      
      before :each do
        @hearts.load_deck
      end
      
      it "should not change the number of cards when shuffling" do
        expect{ @hearts.shuffle_cards }.to_not change{ @hearts.deck.length }
      end

      it "should shuffle the cards correctly" do
        old_top = []
        new_top = []
        matches = 0
        top = 0

        52.times do |i|
          old_top << @hearts.deck[51 - i]
        end
        @hearts.shuffle_cards
        52.times do |i|
          new_top << @hearts.deck[51 - i]
        end
        52.times do |i|
          matches += 1 if (old_top[i] == new_top[i])
        end

        matches.should < 20
      end
      
    end
    
    context "#dealing" do
      
      before :each do
        @hearts.load_deck
        @hearts.deal_cards
      end
      
      after :each do
        @hearts.load_players
      end
      
      it "should deal 13 cards to each player" do
        @hearts.players.each do |player|
          player.hand.length.should == 13
        end
        @hearts.deck.length.should == 0
      end
      
      it 'should not deal any duplicate cards to one player' do
        @hearts.players.each do |player|
          player.hand.each do |card|
            other_cards = [] + player.hand
            expect{ other_cards.delete(card) }.to change{ other_cards.length }.from(13).to(12)
            other_cards.include?(card).should be_false
          end
        end
      end
      
      it "should not deal any duplicate cards to other players" do
        match = []
        @hearts.players.each do |player|
          other_players = [] + @hearts.players
          other_players.delete(player)
          others_cards = []
          other_players.each do |other|
            others_cards << other.hand
          end
          player.hand.each do |card|
            match << others_cards.include?(card)
          end
        end 
        match.length.should == 52
        match.include?(true).should be_false
      end
      
      
    end
    
    context "#play_hand" do
      
      before do
        @hearts.load_deck
        @hearts.deal_cards
      end
      
      it "should take one card from every player" do
        @hearts.play_hand
        @hearts.players.each do |player|
          player.hand.length.should == 12
        end
      end
      
      it "should put 4 more cards in the deck" do
        @hearts.play_hand
        @hearts.deck.length.should == 4
      end
      
    end
    
    context "#whole_game" do
      it "should 'play' a game of hearts and determine a winner" do
        @hearts.game_over?.should == false
        @hearts.play_game
        @hearts.game_over?.should == true
        @hearts.players.include?(@hearts.winner).should == true
      end
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