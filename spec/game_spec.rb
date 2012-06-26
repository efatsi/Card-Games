require 'spec_helper'

describe Game do
  
  before :each do
      @game = Game.new :type
  end
  
  describe "#new" do
    it "takes a game type and returns a game" do
      @game.should be_an_instance_of Game
    end
  end
  
  describe "#new_hearts" do
    it "should show that the game type is hearts" do
      @hearts = Game.new :hearts
      @hearts.type.should eql :hearts
    end
  end
  
  
end