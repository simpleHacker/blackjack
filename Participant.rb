class Participant
  attr_accessor :hand, :curr_total, :status_in_round, :status_in_game, :blackjack
  
  def initialize()
    @hand = []
    @curr_total = 0
    @status_in_game = "play"
    @status_in_round = "play"
    @blackjack = 0
  end
  
  def card_value(card)
    if card.to_i != 0
      card
    elsif ["J","Q","K"].include? card
      10
    elsif card == "A"
      11
    end
  end
  
  # sum up hand total value
  def card_sum(total,value)
    if value.to_i != 0
      total += value
    elsif ["J","Q","K"].include? value
      total += 10;
    elsif value == "A"
      if (total+11) > 21
        total += 1
      else
        total += 11
      end
    end
    total
  end
  
  def calculate_total
    total = 0;
    @hand.each do |value|    
      total = card_sum(total,value)
    end
    @curr_total = total
    total
  end
end



