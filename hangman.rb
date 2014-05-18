#!/usr/bin/env ruby

require 'random-word'
require 'io/console'
require 'colorize'
load 'gallows.rb'

def prompt_player(arr, player_word, chances_left)
  puts "Word: #{player_word}"
  puts "Chances remaining: #{chances_left}"
  print "Letters guessed: "
  print_arr(arr)
  print "\nGuess a single letter (a-z) or the entire word: "
end

def word_check(word, str)
  if check_for_win(word, str)
  else
    puts "Sorry, that is not the correct word. Better luck next time...".red
    puts "The word was: ".red + "#{str}".light_blue
  end
end

def update_word(guess, hidden, player_word)
  count = 0
  times_found = 0
  hidden.length.times do
    if hidden[count] == guess
      player_word[count] = guess
      times_found += 1
    end
    count += 1
  end
  puts "Found #{times_found} occurrence(s) of the character #{guess}.\n\n".light_blue
end

def check_for_win(player_word, hidden)
  if player_word == hidden
    puts "\nCongratulations, you've correctly guessed the word ".green + "\"#{hidden}\"!".light_blue
    return true
  else
    return false
  end
end

def print_arr(arr)
  arr.each do |i|
    print "#{i} "
  end
end

def check_input(str)
  while !(str >= "a" && str <= "z")
    puts "Please enter a letter."
    str = gets.chomp
    str = str.chomp.downcase
  end
  return str
end

def no_chances(hidden)
  puts "You're out of chances, better luck next time..."
  puts "The word was: #{hidden}"
end

def end_prompt(user_choice)
  puts "\nPress P to play again. Press any other letter/number or <enter> to exit."
  user_choice = STDIN.getch.downcase
  puts "\n\n\n"
  return user_choice
end

#==============================================================================
user_choice = "p"

while user_choice == "p"
  puts "Welcome to Hangman!\n\n"

  letters_guessed = []

  # Initialize word bank and choose random word
  # NOTE: word_bank = %w[dumpling soup five alarming full tasty boston]
  hidden_noun = RandomWord.nouns.next
  hidden_adj = RandomWord.adjs.next
  hidden_words = [hidden_noun, hidden_adj]

  hidden = hidden_words.sample
  if hidden.include?("_")
    hidden = hidden[0...hidden.index("_")]
  end

  # Show word progress
  player_word = "_" * hidden.length
  chances_left = hidden.length + 2 # TODO should this be sth else? Important for gameplay, not for overall funvtion
  chances_total = chances_left

  # So long as user has not guessed the word...
  while player_word != hidden
    prompt_player(letters_guessed, player_word, chances_left)
    guess = gets.chomp # TODO get rid of this?
    guess = check_input(guess)
    if guess.length > 1 # If user guesses a word
      word_check(guess, hidden)
      break
    else # If user guesses a letter
      if !letters_guessed.include?(guess)
        letters_guessed << guess
        if hidden.include?(guess) # If guessed letter is in word
          update_word(guess, hidden, player_word)
          print_gallows(chances_left, chances_total)
          check_for_win(player_word, hidden)
        else # If guessed letter is not in word
          chances_left -= 1
          puts "\nSorry, no ".yellow + "#{guess}".light_blue + "'s found.".yellow
          print_gallows(chances_left, chances_total)
          if chances_left == 0
            no_chances(hidden)
            break
          end
        end
      else
        puts "You already used that letter!\n\n".yellow
      end
    end
  end
  user_choice = end_prompt(user_choice) # Allow user either to play again or to close program
end
