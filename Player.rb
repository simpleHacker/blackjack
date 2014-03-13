require 'Participant'

#status_in_round- {play (continue), busts (lose), stand (stop)} : players' current status in a hand round
#status_in_game - {play (continue), split (play two hands in a round), leave} : players' current status in game
#actions : hit; stand, split, doubling down, leave

# hand round -- for one hand 
# deal -- at beginning, or directly served by dealer
# game round -- start another hand

class Player < Participant
  attr_accessor :id, :money, :is_split, :next_hand, :bet, :next_total, :next_bet # for split
  #is_plit: (action as split)
  #next_bet: next hand bet, it equal to bet according to rule
  
  def initialize(id)
    super()
    @money = 1000
    @bet = 0
    @id = id
    @is_split = 0
    @next_hand = []
    @next_total = 0
    @next_bet = 0
  end
  
  # reset at the beginning of each round
  def reset
    @bet = 0
    @is_split = 0
    @next_hand.clear
    @next_total = 0
    @next_bet = 0
    @hand.clear
    @curr_total = 0
    @status_in_game = "play"
    @status_in_round = "play"
    @blackjack = 0
  end
  
  def print_info
    puts "player #{@id} information:"
    puts "current hand: #{@hand.join(",")}"
    puts "cards value: #{@curr_total}"
    puts "bet value: #{@bet}"
    puts "money: #{@money}"
    
    if @next_hand.length != 0
      puts "next hand: #{@next_hand.join(",")}"
    end
    #puts "status in round: #{@status_in_round}"
    #puts "status in game: #{@status_in_game}\n\n"
  end  
  
  
  # split the current hand
  # [rule] do not allow further split here
  def split
    puts ">>>Action: player #{@id} split the cards<<<"
    card = @hand.pop
    @next_hand << card
    @status_in_game = "split"
    # hand card == "A", only deal two card to each
    if @hand[0] == "A"
      @status_in_round = "stand"
    end
    @curr_total = @curr_total/2
    @next_total = @curr_total
    @next_bet = @bet
    @is_split = 1
  end
  
  def switch_hand
    @curr_total, @next_total = @next_total, @curr_total
    @next_hand, @hand = @hand, @next_hand
    @bet, @next_bet = @next_bet, @bet
    calculate_total # update current total value of the card after swith
  end
  
  def play_next_hand
    puts "Play the second hand on split"
    switch_hand
    @status_in_game = "play"
  end

  
  # deal with doubling down action, change self status during doubling down
  # 1, doubling down amount check is before each hand round by -- game control
  # 2, when doubling down, can only get another hit, then must stand
  # 3, if already blackjack, cannot doubling down -- game control
  def doubling_down
    puts ">>>Action: player #{@id} double down the bet<<<"
    valid = false
    while (!valid)
      puts "please input your double down bet amount:"
      amount = gets.to_i
      if amount <= @bet and amount > 0
        @bet += amount
        @money -= amount
        @status_in_round = "stand"
        valid = true
      else
        puts "wrong bet amount, please input it again!"
      end  
    end  
  end
  
  def bust
    puts "player #{@id}, you lose this round, try next round, good luck!\n\n"
    @bet = 0
    @status_in_round = "busts"
  end
  
  def split_lose
    puts "Player #{@id}, you lose this hand, try next hand, good luck!\n\n"
    @bet = 0
    @curr_total, @next_total = @next_total, @curr_total
    @next_hand, @hand = @hand, @next_hand
    @bet, @next_bet = @next_bet, @bet
    
    calculate_total
    @status_in_game = "play" 
  end
  
  def lose
    puts "Player #{@id}, you lose this round, try next round, good luck!\n\n"
    @bet = 0
  end
  
  def push
    puts "Player #{@id}, you get equal with dealer in this round, try next round, good luck!\n\n"
    @money += @bet
  end
  
  def win
    puts "Player #{@id}, you win this hand, good luck to your next round!\n\n"
    if @is_split == 0
      # blackjack case
      if @blackjack == 1
        @money += @bet*2.5
      else
        @money += @bet*2
      end
    else
      @money += @bet*2
    end
  end
  
  
  
end