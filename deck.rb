class Deck
  
  attr_accessor :cards
  
  def initialize
    @cards = (2..10).map{|i| "#{i}C"}+["JC","QC","KC","AC"]+(2..10).map{|i| "#{i}H"}+["JH","QH","KH","AH"]+
    (2..10).map{|i| "#{i}S"}+["JS","QS","KS","AS"]+(2..10).map{|i| "#{i}D"}+["JD","QD","KD","AD"]
  end
  
end