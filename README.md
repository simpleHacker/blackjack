blackjack
=========

Ruby code for Blackjack game

== Running Guidance ==
=== Linux ===
# first, put the whole folder under your directory
# second, cd blackjack
# third, chmod 775 Blackjack.rb
# fourth, ruby Blackjack.rb; (or ./Blackjack.rb)
# last, follow the command guides on screen, and interact with the game

=== Windows ===
If you have eclipse with Aptana studio 3 or Radris, 
directly import the project and run

=== playing hints ===
* Following the scripts printed on screen, and act.
* information print
# every time, before a player's round begin, and after his/her action, player's info will be printed
# so Player can refer to their information for their actions

* For split action:
# it will let you play the first hand firstly, show as current hand
# after finished the fist hand play, then you can play the second hand, show it as current hand
# you always see you play the current hand in split, but they will play two hands in turn

== Game Rules ==
refer to [http://www.pagat.com/banking/blackjack.html]
for some choice may differ from this reference is detailed as below:
* split:
*# do not accept further more split after one split for any case
*# when blackjack, and dealer blackjack, push

* win 
*# regular win
*# score equal to dealer, but has less cards

* push
take push as equal for all cases, no one wins is push

* does not set constraints to the amount of bet for each round

* leave
player can choose to leave at the end of each round

== Code Introduction ==
* Dealer class: 
describe all the behaviors acted by dealer, such as deal card, shuffle cards, hit, and so on

* Player class: 
describe all the behaviors acted by player, such as split, double down bet, lose, win, and so on

* Participant class: 
the base class for dealer and player, because they share some same behavior, 
like calculate the total value of their hand. Also they have some same status in game.

* Game: describe the logic, control and procedure of the game playing

* Blackjack.rb : executible entry to the blackjack game

```Hope you enjoy the game``` 
```Thank you!```