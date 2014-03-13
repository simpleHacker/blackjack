require 'Player'
require 'Dealer'

class Game
  @@deck = [2,3,4,5,6,7,8,9,10,"J","Q","K","A"]
  
  attr_accessor :players, :dealer
  def initialize()
    @decks_cards = []
    @players = []
  end
  
  # start a game: game whole procedure
  def play_game
    initiate_game
    run_game
    puts ""
    puts "###   Thanks for playing Ray's Blackjack game!   ###"
    puts "####################################################"
  end
  
  # initiate game: register player, dealer, decks of card, initial shuffle
  def initiate_game
    puts "#####################################################"
    puts "#          Welcome to Ray's Blackjack Game          #"
    puts "# Are you ready to give your friend Ray some money? #"
    puts "# I know you will. Let's roll                       #"
    puts "#####################################################\n\n"
    # get number of players in game
    puts "How many players in the game?"
    @num_players = gets.to_i
    # get number decks used
    puts "How many decks of cards used in the game?"
    @num_decks = gets.to_i
    # generate the decks of cards used in game
    (@num_decks*4).times {@decks_cards += @@deck}

    @dealer = Dealer.new(@decks_cards)

    @dealer.shuffle(@dealer.decks_cards)
    #register players into game
    @num_players.times do |id|
      player = Player.new(id)
      player.status_in_game = "play"
      player.status_in_round = "play"
      @players << player
    end
  end 
  
  def run_game
    while (@players.length != 0)
      play_round
      # exit the game
      puts "Do you want to end the game: (Y/N)"
      command  = gets.chomp
      valid = false
      while (!valid)
        if command == "Y" or command == "N"
          valid = true
        else
          puts "Warning: Wrong input, please input 'Y' or 'N':"
          command = gets.chomp
        end 
      end
      
      if command == "Y"
        break
      end
      system "clear"
    end   
  end
  
  # start a round: round whole procedure
  def play_round
    puts "============ New Round ============"   
    get_player_bet
    
    @dealer.deal_cards(@players)
    # one round running
    run_round
    # dealer turn
    @dealer.dealer_turn
    # after run round, compare with dealer, and judge lose or win or push for each player
    judge
    # ask player for stay or leave
    stay_leave
    # clean up the round
    cleanup
    puts "============ This Round is end ============\n\n"
    system "clear"
  end
  
  # make each player to input their bet for the round
  def get_player_bet
    @players.each do |player|
      valid = false
      puts "Player #{player.id}, (Money: #{player.money}), please bet for this round(input integer):"
      while (!valid)
        bet = gets.to_i
        if bet <= player.money and bet > 0 and bet.is_a? Integer
          player.bet = bet
          player.money -= bet
          valid = true
        elsif bet.is_a? Integer
          puts "Warning: Not a integer bet, please input your bet again!:"
        elsif bet > player.money
          puts "Warning: Bet cannot be larger than your current money, please input your bet again!:"
        elsif bet <=0
          puts "Warning: Bet cannot be smaller than or equal to 0, please input your bet again!:"
        end
      end
    end
  end
  
  # run round: ask for side rules, and actions
  def run_round
    @players.each do |player|    
      round_info(player)
      counter = 0
      while (player.status_in_round == "play")
        counter += 1
        action = ask_for_action(player,counter)
    
        case action
        when "hit"
          @dealer.hit_player(player)
        when "stand"
          if player.status_in_game != "split"
            player.status_in_round = "stand"
          else
            player.play_next_hand
            curr_info(player)
            next
          end
        when "doubling"
          player.doubling_down
          @dealer.hit_player(player)
        when "split"
          player.split
          @dealer.split_deal(player)
        else
          puts "Warning: No such action, please input action again!"
          next
        end  
        
        curr_info(player)
        
        if player.curr_total > 21
          puts "You Busts! Ray will take your money for this hand, thanks\n\n"
          if player.status_in_game != "split"
            player.bust
          else
            player.split_lose
            puts "\n Please play your second hand on split"
            curr_info(player)
          end
        elsif player.curr_total == 21
          puts "You got 21, please take a rest"
          if player.status_in_game != "split" 
            player.status_in_round = "stand"
          else
            player.play_next_hand
            curr_info(player)
          end                  
        end  
      end  
      puts "========== Player #{player.id}'s turn end ==========\n\n"
    end   
  end
  
  # judge the results for each player in this round
  def judge
    @players.each do |player|
      if player.status_in_round == "busts"
        if player.is_split == 0
          next
        else
          if player.next_bet == 0
            next
          else
            player.switch_hand
            compare(@dealer,player)
          end
        end 
      else  
        compare(@dealer,player)
        # check another hand for split
        if player.next_bet > 0
          player.switch_hand
          puts "For player #{player.id}'s second hand:"
          compare(@dealer,player)
        end
      end
    end
  end
 
  # compare and results for win, lose, and push- equal
  def compare(dealer, player)
    if dealer.curr_total > 21
      player.win   
    elsif dealer.curr_total > player.curr_total
      player.lose
    elsif dealer.curr_total == player.curr_total
      if dealer.hand.length < player.hand.length
        player.lose
      elsif dealer.hand.length == player.hand.length
        player.push
      else
        player.win
      end
    else
      player.win
    end
  end
  
  # ask for stay or leave
  def stay_leave
    @players.each do |player|
      puts "## Player #{player.id} status information: ##"
      puts "Money: #{player.money}"
      #puts "Status in game: #{player.status_in_game}"
      puts "#####################################\n\n"
      
      puts "Player #{player.id}, do you stay or leave (S/L):"
      decision = gets.chomp
      valid = false
      while (!valid)
        if decision != "S" and decision != "L"
          puts "Warning: Invalid input, please input 'S' or 'L' as stay or leave"
          decision = gets.chomp
        else
          valid = true
        end
      end 
      
      if decision == "L"
        player.status_in_game = "leave"
      end
    end
  end
  
  # clean up and reset player and dealer's status
  def cleanup
    qualify_players
    reset_players
    @dealer.cleanup
  end
  
  # decide if the player is out and reset active players for new round
  def qualify_players
    @players.delete_if do |player|
      if player.money == 0
        puts "Warning: Player #{player.id}, has no money, will be out of game!"
        true
      elsif player.status_in_game == "leave"
        puts "Player #{player.id}, nice game with you, see you next time"
        true
      end
    end
  end
  
  # players status reset for new round
  def reset_players
    @players.each do |player|
      player.reset
    end
  end
      
  # print out current round dealer and player status
  def round_info(player)
    puts ""
    puts "++++++ player #{player.id}'s turn start information ++++++"
    puts "dealer's card: #{@dealer.hand[0]}"
    player.print_info
    puts "---------------------------------\n\n"
  end
  
  # player current info
  def curr_info(player)
    puts "### After action information ###"
    puts "player #{player.id}'s information:"
    puts "current hand: #{player.hand.join(",")}"
    puts "cards' value: #{player.curr_total}"
    #if player.is_split == 1
    #  puts "split next hand cards: #{player.next_hand.join(",")}"
    #end
    #puts "status in round: #{player.status_in_round}"
    #puts "status in game: #{player.status_in_game}"
    puts "*****************************\n\n"
  end

 # ask player for action in each personal round 
  def ask_for_action(player,counter)
    actions = []
    actions1 = ["hit","stand"]
    actions2 = ["hit", "stand", "doubling"]
    actions3 = ["hit", "stand", "split", "doubling"]
    if (counter > 1) or (player.money == 0)
      actions = actions1
    elsif (player.money < player.bet) or (player.card_value(player.hand[0]) != player.card_value(player.hand[1]))
      actions = actions2
    else 
      actions = actions3
    end
    
    action=""
    valid = false
    while (!valid)
      puts "Player #{player.id}, please input your action - [#{actions.join(",")}]:"
      action = gets.chomp
      if actions.include? action
        valid = true
      else
        puts "Warning: wrong action, please input allowed action!"
      end
    end
    action
  end

  
end




