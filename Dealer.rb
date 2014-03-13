require 'Participant'

class Dealer < Participant
  attr_accessor :used_cards, :cards_in_deal, :decks_cards
  
  def initialize(new_decks_cards)
    super()
    @used_cards = []
    @cards_in_deal = []
    @decks_cards = new_decks_cards
  end
  
  def add_card(hand, card)
    if card == "A"
      hand << card
    else
      hand.unshift(card)
    end
  end
  
  def print_info
    puts "dealer's hand: #{@hand.join(",")}"
    puts "dealer's cards value: #{@curr_total}\n\n"
  end  
  
  def hit_player(player)
    puts ">>>Action: dealer hit player #{player.id}<<<"
    if @decks_cards.length == 0
      reorganize_cards
    end
    card = @decks_cards.pop  
    add_card(player.hand,card)
    
    @cards_in_deal << card
    player.calculate_total
  end
  
  def hit
    if @decks_cards.length == 0
      reorganize_cards
    end
    card = @decks_cards.pop
    add_card(@hand,card)
    
    @cards_in_deal << card
    calculate_total
  end
  
  def dealer_turn
    while @curr_total < 17
      hit
    end
    puts "Dealer's hand: #{@hand.join(",")}"
    puts "Dealer's cards value: #{@curr_total}"
  end
  
  def split_deal(player)
    puts ">>>Action: dealer hit player #{player.id} for split<<<"
    if @decks_cards.length <2 
      reorganize_cards
    end
    card1 = @decks_cards.pop
    card2 = @decks_cards.pop
    add_card(player.hand,card1)
    add_card(player.next_hand,card2)
    @cards_in_deal.concat([card1, card2])
    player.calculate_total
  end
    
  # deal card and calculate the curr_total  
  # if player already hold blackjack, directly adopt "stand" action when deal the card
  def deal_cards(players)
    puts ">>>Action: dealer deals the cards to all players<<<"
    players.each do |player|
      if @decks_cards.length < 2
        reorganize_cards
      end
      
      card1 = @decks_cards.pop
      card2 = @decks_cards.pop
      @cards_in_deal.concat([card1, card2])
      player.hand = [card1,card2] 
        
      puts "Player #{player.id}'s current hand: #{player.hand.join(",")}"
      if player.calculate_total == 21
        player.blackjack = 1
        player.status_in_round = "stand"
      end
    end
    
    if @decks_cards.length < 2
        reorganize_cards
    end
    card1 = @decks_cards.pop
    card2 = @decks_cards.pop
    @cards_in_deal.concat([card1, card2])
    @hand = [card1, card2]
    calculate_total   
    puts "dealer's card: #{card1}"  
  end
  
  def collect_used_cards
    @used_cards.concat(@cards_in_deal)
  end
  
  def reset
    @cards_in_deal.clear
    @used_cards.clear
    @hand.clear
    @curr_total = 0
  end
  
  def cleanup
    collect_used_cards
    reorganize_cards
    reset
  end
  
  def reorganize_cards
    puts ">>>Action: Reorganize cards<<<"
    if @used_cards.length == 0 and @decks_cards.length == 0
      abort("no more cards for this table, game hault!")
    else  
      @decks_cards.concat(@used_cards)
      @decks_cards.compact
      shuffle(@decks_cards)
      @used_cards.clear
    end
  end
 
 #shuffle the cards
  def shuffle(cards)
    for i in 0..cards.length-1
      index = rand(cards.length-i)+i
      temp = cards[i]
      cards[i] = cards[index]
      cards[index] = temp
    end
  end  
    
end