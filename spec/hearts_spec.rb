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
        @hearts.return_cards
      end

      it "should deal 13 cards to each player" do
        @hearts.players.each do |player|
          player.hand.length.should == 13
        end
        @hearts.deck.length.should == 0
        @hearts.played.length.should == 0
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

    context "#first_hand" do

      before :each do
        @hearts.deal_cards
        @hearts.play_hand
      end
      
      after :each do
        @hearts.return_cards
      end

      it "should take one card from every player" do
        @hearts.players.each do |player|
          player.hand.length.should == 12
        end
      end

      it "should put 4 more cards in someone's round_collection" do
        total = 0
        @hearts.players.each do |player|
          total += player.round_collection.length
        end
        total.should == 4
      end

    end

    context "#13_hands" do

      before do
        @hearts.deal_cards
        13.times { @hearts.play_hand }
      end
      
      after :each do
        @hearts.return_cards
      end

      it "should empty the players hands" do
        @hearts.players.each do |player|
          player.hand.length.should == 0
        end
      end

      it "should fill the round_collections" do
        total = 0
        @hearts.players.each do |player|
          total += player.round_collection.length
        end
        total.should == 52
      end

    end
    
    context "#scoring" do
      
      before :all do
        @hearts.load_deck
      end
      
      after :each do
        @hearts.return_cards
        @hearts.reset_total_scores
      end
      
      it "should know the suit of the card" do
        "2C".suit.should == :club
        "2H".suit.should == :heart
        "2S".suit.should == :spade
        "2D".suit.should == :diamond

        "10C".suit.should == :club
        "10H".suit.should == :heart
        "10S".suit.should == :spade
        "10D".suit.should == :diamond

        "JC".suit.should == :club
        "QH".suit.should == :heart
        "KS".suit.should == :spade
        "AD".suit.should == :diamond
      end
      
      it "should properly record round scores after a scattered round" do
        52.times do |i|
          @hearts.players[i%4].round_collection << @hearts.deck[i]
          # players[0] has 5H 9H KH QS
          # players[1] has 2H 6H 10H AH
          # players[2] has 3H 7H JH 
          # players[3] has 4H 8H QH 
        end
        @hearts.update_round_scores
        @hearts.players[0].round_score.should == 16
        @hearts.players[1].round_score.should == 4
        @hearts.players[2].round_score.should == 3
        @hearts.players[3].round_score.should == 3
      end

      it "should properly record round scores after a suit-swept round" do
        52.times do |i|
          @hearts.players[i/13].round_collection << @hearts.deck[i]
          # players[0] has all clubs
          # players[1] has all hearts
          # players[2] has all spades
          # players[3] has all diamonds
        end
        @hearts.update_round_scores
        @hearts.players[0].round_score.should == 0
        @hearts.players[1].round_score.should == 13
        @hearts.players[2].round_score.should == 13
        @hearts.players[3].round_score.should == 0
      end
      
      
      it "should properly record round scores after a totally-swept round" do
        52.times do |i|
          @hearts.players[1].round_collection << @hearts.deck[i]
          # players[1] has all the cards
        end
        @hearts.update_round_scores
        @hearts.players[0].round_score.should == 0
        @hearts.players[1].round_score.should == 26
        @hearts.players[2].round_score.should == 0
        @hearts.players[3].round_score.should == 0
      end
      
      it "should properly record total_scores after a scattered round" do
        52.times do |i|
          @hearts.players[i%4].round_collection << @hearts.deck[i]
        end
        @hearts.update_total_scores
        @hearts.players[0].total_score.should == 16
        @hearts.players[1].total_score.should == 4
        @hearts.players[2].total_score.should == 3
        @hearts.players[3].total_score.should == 3        
      end
      
      it "should properly record total_scores after a suit-swept round" do
        52.times do |i|
          @hearts.players[i/13].round_collection << @hearts.deck[i]
        end
        @hearts.update_total_scores
        @hearts.players[0].total_score.should == 0
        @hearts.players[1].total_score.should == 13
        @hearts.players[2].total_score.should == 13
        @hearts.players[3].total_score.should == 0
      end
      
      it "should properly record total_scores after a totally-swept round" do
        52.times do |i|
          @hearts.players[1].round_collection << @hearts.deck[i]
        end
        @hearts.update_total_scores
        @hearts.players[0].total_score.should == 26
        @hearts.players[1].total_score.should == 0
        @hearts.players[2].total_score.should == 26
        @hearts.players[3].total_score.should == 26
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