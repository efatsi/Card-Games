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
  
end