require 'spec_helper'

describe Spades do

  before :all do
    @spades = Spades.new
  end

  describe "#setup" do
    
    context "#new_spades" do

      it "should show that spades has been initiated" do
        @spades.should be_an_instance_of Spades
      end

    end
    
    context "#get_deck" do
      
      before :each do
        @spades.load_deck
      end
      
      it "should return a new array" do
        @spades.deck.should be_an_instance_of Array
      end
      it "should show that deck has 52 cards" do
        @spades.deck.length.should == 52
      end
      it "should show deck has all the cards" do
        deck_string = []
        @spades.deck.each do |card|
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
        @spades.load_players
      end
      
      it "should show required number of players" do
        @spades.size.should == 4
      end
      
      it "should load in required number of players" do
        @spades.players.length.should == @spades.size
      end
      
      it "should have made 2 teams of 2" do
        @spades.team_1.should_not be_nil
        @spades.team_1.players.length.should == 2
        @spades.team_2.should_not be_nil
        @spades.team_2.players.length.should == 2
      end
      
      it "should have picked a dealer" do
        @spades.dealer.should_not be_nil
        @spades.players.include?(@spades.dealer).should == true
      end

    end
  
    context "#player_team_relations" do
      
      before :each do
        @spades.load_players
      end
      
      it "a change in a player should relate to a change in a team's player" do
        @spades.players[0].name = "THIS IS A FAKE NAME"
        @spades.team_1.players[0].name.should == "THIS IS A FAKE NAME"
      end
      
      it "should be able to get the team a player is on" do
        @spades.team_1.players[0].team.should == @spades.team_1
        @spades.team_1.players[1].team.should == @spades.team_1
        @spades.team_2.players[0].team.should == @spades.team_2
        @spades.team_2.players[1].team.should == @spades.team_2
      end
      
    end
    
  end

  describe "#game_play" do

    context "#dealer_assignment" do
      
      before :each do
        @spades.load_players
      end
      
      it "should have a dealer" do
        @spades.dealer.should_not be_nil
      end

      it "reset dealer should choose next player in @players array" do
        old_dealer_index = @spades.players.index(@spades.dealer)
        @spades.change_dealer
        new_dealer_index = @spades.players.index(@spades.dealer)
        new_dealer_index.should == (old_dealer_index + 1) % 4
      end

      it "dealer should be the same after 4 dealer changes" do
        current_dealer = @spades.dealer
        4.times do
          @spades.change_dealer
        end
        current_dealer.should == @spades.dealer
      end

    end

    context "#shuffling" do

      before :each do
        @spades.load_deck
      end

      it "should not change the number of cards when shuffling" do
        expect{ @spades.shuffle_cards }.to_not change{ @spades.deck.length }
      end

      it "should shuffle the cards correctly" do
        old_top = []
        new_top = []
        matches = 0
        top = 0

        52.times do |i|
          old_top << @spades.deck[51 - i]
        end
        @spades.shuffle_cards
        52.times do |i|
          new_top << @spades.deck[51 - i]
        end
        52.times do |i|
          matches += 1 if (old_top[i] == new_top[i])
        end

        matches.should < 20
      end

    end

    context "#dealing" do

      before :each do
        @spades.load_players
        @spades.load_deck
        @spades.shuffle_cards
        @spades.deal_cards
      end

      after :each do
        @spades.return_cards
      end

      it "should deal 13 cards to each player" do
        @spades.players.each do |player|
          player.hand.length.should == 13
        end
        @spades.deck.length.should == 0
        @spades.played.length.should == 0
      end
      
      it "should deal non-nil cards to all players" do
        @spades.players.each do |player|
          player.hand.each do |card|
            card.should_not be_nil
          end
        end
      end

      it 'should not deal any duplicate cards to one player' do
        @spades.players.each do |player|
          player.hand.each do |card|
            other_cards = [] + player.hand
            expect{ other_cards.delete(card) }.to change{ other_cards.length }.from(13).to(12)
            other_cards.include?(card).should be_false
          end
        end
      end

      it "should not deal any duplicate cards to other players" do
        match = []
        @spades.players.each do |player|
          other_players = [] + @spades.players
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
        @spades.return_cards
        dealer_index = @spades.players.index(@spades.dealer)
        top_card = @spades.deck.last
        @spades.deal_cards
        @spades.players[(dealer_index+1)%4].hand.include?(top_card).should == true
      end

    end

    context "#returning_cards" do
      
      before :each do
        @spades.load_players
        @spades.load_deck
        @spades.shuffle_cards
        @spades.deal_cards
      end
      
      it "should leave all players with no cards" do
        @spades.return_cards
        @spades.players.each do |player|
          player.hand.should be_empty
          player.round_collection.should be_empty
        end
      end
      
      it "should leave all players with no cards after a hand" do
        @spades.play_trick
        @spades.return_cards
        @spades.players.each do |player|
          player.hand.should be_empty
          player.round_collection.should be_empty
        end
      end

      it "should leave all players with no cards after 13 hands" do
        13.times { @spades.play_trick }
        @spades.return_cards
        @spades.players.each do |player|
          player.hand.should be_empty
          player.round_collection.should be_empty
        end
      end

      it "should leave all players with no cards after a round" do
        @spades.play_round
        @spades.return_cards
        @spades.players.each do |player|
          player.hand.should be_empty
          player.round_collection.should be_empty
        end
      end
      
    end

    context "#play_round" do
      
      before :each do
        @spades.load_players
        @spades.load_deck
        @spades.shuffle_cards
        @spades.deal_cards
        @spades.play_round
      end
      
      it "should play a round without error" do
        @spades.return_cards
        @spades.play_round
      end
      
      it "should empty the players hands" do
        @spades.players.each do |player|
          player.hand.should be_empty
        end
      end
      
      it "should leave an empty deck" do
        @spades.deck.should be_empty
      end
      
      it "should have distributed 52 cards to players round_collections" do
        collected_count = 0
        @spades.players.each do |player|
          collected_count += player.round_collection.length
        end
        collected_count.should == 52
      end
        
      it "should not have any nil values in round_collections" do
        @spades.players.each do |player|
          player.round_collection.each do |card|
            card.should_not be_nil
          end
        end
      end
      
      it "should have total tricks taken be 13" do
        trick_count = 0
        @spades.teams.each do |team|
          trick_count += team.tricks_won
        end
        trick_count.should == 13
      end
        
    end

    context "#scoring" do
      
      before :each do
        @spades.load_players
        @spades.load_deck
        @team_1 = @spades.team_1
        @team_2 = @spades.team_2
      end
      
      after :each do
        @spades.return_cards
        @spades.reset_scores
      end
      
      it "should properly record a successful round" do
        @team_1.bid = 7
        @team_2.bid = 6
        @team_1.tricks_won = 7
        @team_2.tricks_won = 6
        @spades.update_round_scores
        @team_1.round_score.should == 70
        @team_2.round_score.should == 60
      end
      
      it "should properly record an unsuccessful round" do
        @team_1.bid = 8
        @team_2.bid = 8
        @team_1.tricks_won = 7
        @team_2.tricks_won = 6
        @spades.update_round_scores
        @team_1.round_score.should == -80
        @team_2.round_score.should == -80
      end
      
      it "should properly record a bagged round" do
        @team_1.bid = 6
        @team_2.bid = 6
        @team_1.tricks_won = 7
        @team_2.tricks_won = 6
        @spades.update_round_scores
        @team_1.round_score.should == 60
        @team_2.round_score.should == 60
        @team_1.bags.should == 1
        @team_2.bags.should == 0
      end

      it "should add 100 for a successful nil hand" do

      end

      it "should add 200 for a successful blind_nil hand" do

      end
      
      
    end

  #   context "#check_for_winner" do
  #     
  #     before :each do
  #       @spades.load_players
  #     end
  #     
  #     it "should decide there is no winner" do
  #       @spades.players.each do |player|
  #         player.total_score = 10
  #       end
  #       @spades.check_for_winner
  #       @spades.winner.should be_nil
  #     end
  #     
  #     it "should decide there is a winner when someone has over 100 points" do
  #       @spades.players.first.total_score = 101
  #       @spades.check_for_winner
  #       @spades.winner.should_not be_nil
  #     end
  #     
  #   end
  # 
  #   context "#whole_game" do
  #     
  #     before :each do
  #       @spades.reset
  #     end
  #     
  #     it "should 'play' a game of spades and determine a winner" do
  #       @spades.game_over?.should == false
  #       @spades.play_game
  #       @spades.game_over?.should == true
  #       @spades.players.include?(@spades.winner).should == true
  #     end
  #     
  #   end
  # 
  #   context "#reset" do
  # 
  #     it "should reset the games with no players and no winner" do
  #       @spades.reset
  #       @spades.players.empty?.should == true
  #       @spades.game_over?.should == false
  # 
  #     end
  #     
  #   end
  #   
  # end
  # 
  # describe "#trick_play" do
  #   
  #   context "#determine_leader" do
  #     
  #     before :each do
  #       @spades.load_players
  #       @spades.load_deck
  #       @spades.shuffle_cards
  #       @spades.deal_cards
  #     end
  #     
  #     it "should assign 2 of clubs owner to be leader" do
  #       has_2_of_clubs = false
  #       @spades.leader.hand.each do |card|
  #         has_2_of_clubs = true if card.suit == :club && card.value = "2"
  #       end
  #       has_2_of_clubs.should == true
  #     end
  #       
  #   end
  #   
  #   context "#passing_cards" do
  #     
  #     before :each do
  #       @spades.load_players
  #       @spades.load_deck
  #       @spades.shuffle_cards
  #       @spades.deal_cards
  #     end
  #     
  #     it "should not raise an error" do
  #       @spades.pass_cards("left")
  #       @spades.pass_cards("right")
  #       @spades.pass_cards("across")
  #       @spades.pass_cards("none")
  #     end
  #     
  #     it "should have had cards change hands" do
  #       current_first_hand = @spades.players[0].hand
  #       @spades.pass_cards("left")
  #       new_cards = 0
  #       @spades.players[0].hand.each do |card|
  #         new_cards += 1 unless current_first_hand.include?(card)
  #       end
  #       new_cards.should == 3
  #     end
  # 
  #     it "should have had cards change hands to the left if direction == left" do
  #       current_first_hand = @spades.players[0].hand
  #       @spades.pass_cards("left")
  #       new_cards = 0
  #       @spades.players[1].hand.each do |card|
  #         new_cards += 1 if current_first_hand.include?(card)
  #       end
  #       new_cards.should == 3
  #     end
  # 
  #     it "should have had cards change hands to the left if direction == right" do
  #       current_first_hand = @spades.players[0].hand
  #       @spades.pass_cards("right")
  #       new_cards = 0
  #       @spades.players[3].hand.each do |card|
  #         new_cards += 1 if current_first_hand.include?(card)
  #       end
  #       new_cards.should == 3
  #     end
  # 
  #     it "should have had cards change hands to the left if direction == across" do
  #       current_first_hand = @spades.players[0].hand
  #       @spades.pass_cards("across")
  #       new_cards = 0
  #       @spades.players[2].hand.each do |card|
  #         new_cards += 1 if current_first_hand.include?(card)
  #       end
  #       new_cards.should == 3
  #     end
  # 
  #     it "should have had no cards change hands if direction == none" do
  #       current_first_hand = @spades.players[0].hand
  #       @spades.pass_cards("none")
  #       current_first_hand.should == @spades.players[0].hand
  #     end
  #     
  #   end
  #   
  #   context "#first_trick" do
  # 
  #     before :each do
  #       @spades.load_players
  #       @spades.load_deck
  #       @spades.shuffle_cards
  #       @spades.deal_cards
  #       @spades.play_trick
  #     end
  #     
  #     after :each do
  #       @spades.return_cards
  #     end
  # 
  #     it "should take one card from every player" do
  #       @spades.players.each do |player|
  #         player.hand.length.should == 12
  #       end
  #     end
  # 
  #     it "should put 4 more cards in someone's round_collection" do
  #       total = 0
  #       @spades.players.each do |player|
  #         total += player.round_collection.length
  #       end
  #       total.should == 4
  #     end
  # 
  #   end
  # 
  #   context "#13_tricks" do
  # 
  #     before do
  #       @spades.load_players
  #       @spades.load_deck
  #       @spades.shuffle_cards
  #       @spades.deal_cards
  #       13.times { @spades.play_trick }
  #     end
  #     
  #     after :each do
  #       @spades.return_cards
  #     end
  # 
  #     it "should empty the players hands" do
  #       @spades.players.each do |player|
  #         player.hand.length.should == 0
  #       end
  #     end
  # 
  #     it "should fill the round_collections" do
  #       total = 0
  #       @spades.players.each do |player|
  #         total += player.round_collection.length
  #       end
  #       total.should == 52
  #     end
  # 
  #   end
  # 
  #   context "#lead_suit" do
  #     
  #     before :each do
  #       @spades.load_players
  #       @spades.load_deck
  #       @spades.shuffle_cards
  #       @spades.deal_cards
  #     end
  #     
  #     after :each do
  #       @spades.return_cards
  #     end
  #     
  #     it "should know the lead suit after first card is played" do
  #       @spades.play_trick 
  #       first_card = @spades.last_trick.first
  #       this_lead = first_card.suit
  #       @spades.lead_suit.should == this_lead
  #     end
  #     
  #     it "should limit other players to play the lead suit if they can" do
  #       13.times do |i|
  #         leader_index = @spades.players.index(@spades.leader)
  #         @spades.play_trick
  #         first_card = @spades.last_trick.first
  #         this_lead = first_card.suit
  #         @spades.last_trick.each do |card|
  #           if card.suit != this_lead
  #             index = @spades.played.index(card) - 4*i
  #             @spades.players[(leader_index + index)%4].hand.each do |leftover|
  #               leftover.suit.should_not == this_lead
  #             end
  #           end
  #         end
  #       end
  #     end
  #   
  #   end
  #   
  #   context "#card_beater" do
  #     
  #     it "should correctly determine if one card of same suit beats another" do
  #       values = %w(2 3 4 5 6 7 8 9 10 J Q K A)
  #       values.each do |first_value|
  #         first_card = Card.new(:club, first_value)
  #         values[0, values.index(first_value)].each do |second_value|
  #           second_card = Card.new(:club, second_value)
  #           first_card.beats?(second_card).should == true
  #           second_card.beats?(first_card).should == false
  #         end
  #       end          
  #     end
  # 
  #     it "should have a card not beat another of different suit" do
  #       first_card = Card.new(:club, "A")
  #       second_card = Card.new(:heart, "3")
  #       first_card.beats?(second_card).should == false
  #       second_card.beats?(first_card).should == false
  #     end
  # 
  #     it "should have a card not beat itself (unreal situation)" do
  #       values = %w(2 3 4 5 6 7 8 9 10 J Q K A)
  #       values.each do |value|
  #         first_card = Card.new(:club, value)
  #         second_card = Card.new(:club, value)
  #         first_card.beats?(second_card).should == false
  #         second_card.beats?(first_card).should == false
  #       end
  #     end
  #     
  #   end
  #   
  #   context "#trick_winner" do
  #     
  #     before :each do
  #       @spades.load_players
  #       @spades.leader = @spades.players[rand(4)]
  #     end
  #     
  #     it "should correctly determine the winner of a trick" do
  #       fake_trick = []
  #       @spades.lead_suit = :club
  #       ["2", "3", "4", "5"].each do |value|
  #         fake_trick << Card.new(:club, value)
  #       end
  #       @spades.determine_trick_winner(fake_trick)
  #       @spades.leader.should == @spades.players.last
  #     end
  #     
  #     it "should correctly determine the winner of a trick" do
  #       fake_trick = []
  #       @spades.lead_suit = :club
  #       ["2", "3", "8", "5"].each do |value|
  #         fake_trick << Card.new(:club, value)
  #       end
  #       @spades.determine_trick_winner(fake_trick)
  #       @spades.leader.should == @spades.players[2]
  #     end
  #     
  #     it "should correctly determine the winner of a trick" do
  #       fake_trick = []
  #       @spades.lead_suit = :club
  #       ["2", "3", "8", "A"].each do |value|
  #         fake_trick << Card.new(:club, value)
  #       end
  #       @spades.determine_trick_winner(fake_trick)
  #       @spades.leader.should == @spades.players.last
  #     end
  #     
  #     it "should correctly determine the winner of a trick" do
  #       fake_trick = []
  #       @spades.lead_suit = :club
  #       ["J", "Q", "K", "A"].each do |value|
  #         fake_trick << Card.new(:club, value)
  #       end
  #       @spades.determine_trick_winner(fake_trick)
  #       @spades.leader.should == @spades.players.last
  #     end
  #     
  #     it "should correctly determine the winner of a trick" do
  #       fake_trick = []
  #       @spades.lead_suit = :club
  #       ["A", "Q", "K", "J"].each do |value|
  #         fake_trick << Card.new(:club, value)
  #       end
  #       @spades.determine_trick_winner(fake_trick)
  #       @spades.leader.should == @spades.players.first
  #     end
  #   end
    
  end

end