require 'spec_helper'

describe Hearts do

  before :all do
    @hearts = Hearts.new
  end

  describe "#setup" do
    
    context "#new_hearts" do

      it "should show that hearts has been initiated" do
        @hearts.should be_an_instance_of Hearts
      end

    end
    
    context "#get_deck" do
      
      before :each do
        @hearts.load_deck
      end
      
      it "should return a new array" do
        @hearts.deck.should be_an_instance_of Array
      end
      it "should show that deck has 52 cards" do
        @hearts.deck.length.should == 52
      end
      it "should show deck has all the cards" do
        deck_string = []
        @hearts.deck.each do |card|
          deck_string << card.value.to_s + card.suit.to_s
        end
        %w(club heart spade diamond).each do |suit|
          (2..10).each do |i|
            deck_string.include?(i.to_s + suit.to_s).should == true
          end
          ["J","Q","K","A"].each do |f|
            deck_string.include?(f.to_s + suit.to_s).should == true
          end
        end
      end
    end

    context "#get_players" do
      
      before :each do
        @hearts.load_players
      end
      
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
  
  end

  describe "#game_play" do

    context "#dealer_assignment" do
      
      before :each do
        @hearts.load_players
      end
      
      it "should have a dealer" do
        @hearts.dealer.should_not be_nil
      end

      it "reset dealer should choose next player in @players array" do
        old_dealer_index = @hearts.players.index(@hearts.dealer)
        @hearts.change_dealer
        new_dealer_index = @hearts.players.index(@hearts.dealer)
        new_dealer_index.should == (old_dealer_index + 1) % 4
      end

      it "dealer should be the same after 4 dealer changes" do
        current_dealer = @hearts.dealer
        4.times do
          @hearts.change_dealer
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
        @hearts.load_players
        @hearts.load_deck
        @hearts.shuffle_cards
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
      
      it "should deal non-nil cards to all players" do
        @hearts.players.each do |player|
          player.hand.each do |card|
            card.should_not be_nil
          end
        end
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
      
      it "should deal first card to the 'left' of the dealer" do
        @hearts.return_cards
        dealer_index = @hearts.players.index(@hearts.dealer)
        top_card = @hearts.deck.last
        @hearts.deal_cards
        @hearts.players[(dealer_index+1)%4].hand.include?(top_card).should == true
      end

    end

    context "#returning_cards" do
      
      before :each do
        @hearts.load_players
        @hearts.load_deck
        @hearts.shuffle_cards
        @hearts.deal_cards
      end
      
      it "should leave all players with no cards" do
        @hearts.return_cards
        @hearts.players.each do |player|
          player.hand.should be_empty
          player.round_collection.should be_empty
        end
      end
      
      it "should leave all players with no cards after a hand" do
        @hearts.play_trick
        @hearts.return_cards
        @hearts.players.each do |player|
          player.hand.should be_empty
          player.round_collection.should be_empty
        end
      end

      it "should leave all players with no cards after 13 hands" do
        13.times { @hearts.play_trick }
        @hearts.return_cards
        @hearts.players.each do |player|
          player.hand.should be_empty
          player.round_collection.should be_empty
        end
      end

      it "should leave all players with no cards after a round" do
        @hearts.play_round
        @hearts.return_cards
        @hearts.players.each do |player|
          player.hand.should be_empty
          player.round_collection.should be_empty
        end
      end
      
    end

    context "#play_round" do
      
      before :each do
        @hearts.load_players
        @hearts.load_deck
        @hearts.shuffle_cards
        @hearts.deal_cards
        @hearts.play_round
      end
      
      it "should play a round without error" do
        @hearts.return_cards
        @hearts.play_round
      end
      
      it "should empty the players hands" do
        @hearts.players.each do |player|
          player.hand.should be_empty
        end
      end
      
      it "should leave an empty deck" do
        @hearts.deck.should be_empty
      end
      
      it "should have distributed 52 cards to players round_collections" do
        collected_count = 0
        @hearts.players.each do |player|
          collected_count += player.round_collection.length
        end
        collected_count.should == 52
      end
        
      it "should not have any nil values in round_collections" do
        @hearts.players.each do |player|
          player.round_collection.each do |card|
            card.should_not be_nil
          end
        end
      end
      
      it "should have players' round scores totaling 26 (or 26*3)" do
        @hearts.update_total_scores
        all_round_scores = 0
        @hearts.players.each do |player|
          all_round_scores += player.round_score
        end
        all_round_scores.should == 26        
      end
        
    end

    context "#scoring" do
      
      before :all do
        @hearts.load_players
        @hearts.load_deck
      end
      
      after :each do
        @hearts.return_cards
        @hearts.reset_total_scores
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
      
      before :each do
        @hearts.reset
      end
      
      it "should 'play' a game of hearts and determine a winner" do
        @hearts.game_over?.should == false
        @hearts.play_game
        @hearts.game_over?.should == true
        @hearts.players.include?(@hearts.winner).should == true
      end
      
    end
  
    context "#reset" do

      it "should reset the games with no players and no winner" do
        @hearts.reset
        @hearts.players.empty?.should == true
        @hearts.game_over?.should == false

      end
      
    end
    
  end
  
  describe "#trick_play" do
    
    context "#determine_leader" do
      
      before :each do
        @hearts.load_players
        @hearts.load_deck
        @hearts.shuffle_cards
        @hearts.deal_cards
      end
      
      it "should assign 2 of clubs owner to be leader" do
        has_2_of_clubs = false
        @hearts.leader.hand.each do |card|
          has_2_of_clubs = true if card.suit == :club && card.value = "2"
        end
        has_2_of_clubs.should == true
      end
        
    end
    
    context "#passing_cards" do
      
      before :each do
        @hearts.load_players
        @hearts.load_deck
        @hearts.shuffle_cards
        @hearts.deal_cards
      end
      
      it "should not raise an error" do
        @hearts.pass_cards("left")
        @hearts.pass_cards("right")
        @hearts.pass_cards("across")
        @hearts.pass_cards("none")
      end
      
      it "should have had cards change hands" do
        current_first_hand = @hearts.players[0].hand
        @hearts.pass_cards("left")
        new_cards = 0
        @hearts.players[0].hand.each do |card|
          new_cards += 1 unless current_first_hand.include?(card)
        end
        new_cards.should == 3
      end

      it "should have had cards change hands to the left if direction == left" do
        current_first_hand = @hearts.players[0].hand
        @hearts.pass_cards("left")
        new_cards = 0
        @hearts.players[1].hand.each do |card|
          new_cards += 1 if current_first_hand.include?(card)
        end
        new_cards.should == 3
      end

      it "should have had cards change hands to the left if direction == right" do
        current_first_hand = @hearts.players[0].hand
        @hearts.pass_cards("right")
        new_cards = 0
        @hearts.players[3].hand.each do |card|
          new_cards += 1 if current_first_hand.include?(card)
        end
        new_cards.should == 3
      end

      it "should have had cards change hands to the left if direction == across" do
        current_first_hand = @hearts.players[0].hand
        @hearts.pass_cards("across")
        new_cards = 0
        @hearts.players[2].hand.each do |card|
          new_cards += 1 if current_first_hand.include?(card)
        end
        new_cards.should == 3
      end

      it "should have had no cards change hands if direction == none" do
        current_first_hand = @hearts.players[0].hand
        @hearts.pass_cards("none")
        current_first_hand.should == @hearts.players[0].hand
      end
      
    end
    
    context "#first_trick" do

      before :each do
        @hearts.load_players
        @hearts.load_deck
        @hearts.shuffle_cards
        @hearts.deal_cards
        @hearts.play_trick
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

    context "#13_tricks" do

      before do
        @hearts.load_players
        @hearts.load_deck
        @hearts.shuffle_cards
        @hearts.deal_cards
        13.times { @hearts.play_trick }
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

    context "#lead_suit" do
      
      before :each do
        @hearts.load_players
        @hearts.load_deck
        @hearts.shuffle_cards
        @hearts.deal_cards
      end
      
      after :each do
        @hearts.return_cards
      end
      
      it "should know the lead suit after first card is played" do
        first_card = @hearts.leader.hand.last
        lead_suit = first_card.suit
        @hearts.play_trick
        @hearts.lead_suit.should == lead_suit
      end
      
      it "should limit other players to play the lead suit if they can" do
        13.times do |i|
          first_card = @hearts.leader.hand.last
          leader_index = @hearts.players.index(@hearts.leader)
          lead_suit = first_card.suit
          @hearts.play_trick
          @hearts.last_trick.each do |card|
            if card.suit != lead_suit
              index = @hearts.played.index(card) - 4*i
              @hearts.players[(leader_index + index)%4].hand.each do |leftover|
                leftover.suit.should_not == lead_suit
              end
            end
          end
        end
      end
    
    end
    
    context "#card_beater" do
      
      it "should correctly determine if one card of same suit beats another" do
        values = %w(2 3 4 5 6 7 8 9 10 J Q K A)
        values.each do |first_value|
          first_card = Card.new(:club, first_value)
          values[0, values.index(first_value)].each do |second_value|
            second_card = Card.new(:club, second_value)
            first_card.beats?(second_card).should == true
            second_card.beats?(first_card).should == false
          end
        end          
      end

      it "should have a card not beat another of different suit" do
        first_card = Card.new(:club, "A")
        second_card = Card.new(:heart, "3")
        first_card.beats?(second_card).should == false
        second_card.beats?(first_card).should == false
      end

      it "should have a card not beat itself (unreal situation)" do
        values = %w(2 3 4 5 6 7 8 9 10 J Q K A)
        values.each do |value|
          first_card = Card.new(:club, value)
          second_card = Card.new(:club, value)
          first_card.beats?(second_card).should == false
          second_card.beats?(first_card).should == false
        end
      end
      
    end
    
    context "#trick_winner" do
      
      before :each do
        @hearts.load_players
        @hearts.leader = @hearts.players[rand(4)]
      end
      
      it "should correctly determine the winner of a trick" do
        fake_trick = []
        @hearts.lead_suit = :club
        ["2", "3", "4", "5"].each do |value|
          fake_trick << Card.new(:club, value)
        end
        @hearts.determine_trick_winner(fake_trick)
        @hearts.leader.should == @hearts.players.last
      end
      
      it "should correctly determine the winner of a trick" do
        fake_trick = []
        @hearts.lead_suit = :club
        ["2", "3", "8", "5"].each do |value|
          fake_trick << Card.new(:club, value)
        end
        @hearts.determine_trick_winner(fake_trick)
        @hearts.leader.should == @hearts.players[2]
      end
      
      it "should correctly determine the winner of a trick" do
        fake_trick = []
        @hearts.lead_suit = :club
        ["2", "3", "8", "A"].each do |value|
          fake_trick << Card.new(:club, value)
        end
        @hearts.determine_trick_winner(fake_trick)
        @hearts.leader.should == @hearts.players.last
      end
      
      it "should correctly determine the winner of a trick" do
        fake_trick = []
        @hearts.lead_suit = :club
        ["J", "Q", "K", "A"].each do |value|
          fake_trick << Card.new(:club, value)
        end
        @hearts.determine_trick_winner(fake_trick)
        @hearts.leader.should == @hearts.players.last
      end
      
      it "should correctly determine the winner of a trick" do
        fake_trick = []
        @hearts.lead_suit = :club
        ["A", "Q", "K", "J"].each do |value|
          fake_trick << Card.new(:club, value)
        end
        @hearts.determine_trick_winner(fake_trick)
        @hearts.leader.should == @hearts.players.first
      end
    end
    
  end

end