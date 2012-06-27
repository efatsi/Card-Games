require 'spec_helper'

describe CardGame do

  before :all do
    @game = CardGame.new
  end

  describe "#new" do
    it "takes a game type and returns a card game" do
      @game.should be_an_instance_of CardGame
    end
  end
  
  describe "#play_game" do
    it "should show game is not over" do
      @game.game_over?.should == false
    end
    it "should show game is over when winner is chosen" do
      @game.winner = Player.new
      @game.game_over?.should == true
    end
  end 
  
  describe '#reset' do
    it "should reset the game with no winner" do
      @game.winner = Player.new
      @game.game_over?.should == true
      @game.reset
      @game.game_over?.should == false
    end
  end
end