#!/usr/bin/env ruby

require 'random-word'
require 'io/console'
require 'colorize'
load 'gallows.rb'

def word_init
  # Initialize word bank and choose random word
  # NOTE: word_bank = %w[dumpling soup five alarming full tasty boston]
  hidden_noun = RandomWord.nouns.next
  hidden_adj = RandomWord.adjs.next
  hidden_words = [hidden_noun, hidden_adj]

  hidden = hidden_words.sample
  if hidden.include?("_")
    hidden = hidden[0...hidden.index("_")]
  end
  return hidden
end

def prompt_player(arr, player_word, chances_left)
  puts "Word: #{player_word}"
  puts "Chances remaining: #{chances_left}"
  print "Letters guessed: "
  print_arr(arr)
  print "\nGuess a single letter (a-z) or the entire word: "
end

def confirm_word_entry
  print "Are you sure you want to guess a word? ".yellow +
      "You will lose the game if it is wrong. ".yellow +
      "Press ".yellow + "C".cyan + " to confirm or any other letter ".yellow +
       "(or <enter>) to go back and guess again.".yellow
   word = STDIN.getch.downcase
   puts "\n\n"
  return word
end

def word_check(word, str, chances_left, chances_total)
  if check_for_win(word, str)
  else
    chances_left = 0
    print_gallows(chances_left, chances_total)
    puts "Sorry, that is not the correct word. Better luck next time...".red
    puts "The word was: ".red + "#{str}".cyan
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
  puts "Found ".green + "#{times_found}".cyan + " occurrence(s) of the letter ".green +
  "#{guess}.\n\n".cyan
end

def check_for_win(player_word, hidden)
  if player_word == hidden
    puts "\nCongratulations, you've correctly guessed the word ".green +
    "\"#{hidden}\"".cyan + "!".yellow
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
    print "Please enter a letter or word: "
    str = gets.chomp
    str = str.chomp.downcase
  end
  return str
end

def no_chances(hidden)
  puts "You're out of chances, better luck next time...".red
  puts "The word was: ".red + "#{hidden}".cyan
end

def end_prompt(user_choice)
  puts "\nPress " + "<enter>".cyan + " to play again. " +
  "Press " + "<esc>".cyan + " to exit."
  user_choice = STDIN.getch.downcase
  while user_choice != "\r" && user_choice != "\e"
    puts "Whoops. Looks like you entered an invalid key. " +
    "press <enter> to play again or <esc> to exit."
    user_choice = STDIN.getch.downcase
  end
  puts "\n\n\n"
  return user_choice
end

#==============================================================================
user_choice = "\r"

while user_choice == "\r"
  puts "Welcome to Hangman!\n\n"

  letters_guessed = []
  user_choice = ""

  hidden = word_init

  # Show word progress
  player_word = "_" * hidden.length
  chances_left = hidden.length + 2 # TODO should this be sth else? Important for gameplay, not for overall funvtion
  chances_total = chances_left

  print_gallows(chances_left, chances_total)

  # So long as user has not guessed the word...
  while player_word != hidden
    prompt_player(letters_guessed, player_word, chances_left)
    guess = gets.chomp.downcase
    guess = check_input(guess)
    if guess.length > 1 # If user guesses a word; TODO MAKE ALL THIS A NEW LITTLE METHOD
      word_confirmation = confirm_word_entry
      if word_confirmation == "c"
        word_check(guess, hidden, chances_left, chances_total)
        break
      else
        print_gallows(chances_left, chances_total)
      end
    else # If user guesses a letter
      if !letters_guessed.include?(guess)
        letters_guessed << guess
        if hidden.include?(guess) # If guessed letter is in word
          update_word(guess, hidden, player_word)
          print_gallows(chances_left, chances_total)
          check_for_win(player_word, hidden)
        else # If guessed letter is not in word
          chances_left -= 1
          puts "\nSorry, no ".yellow + "#{guess}".cyan + "'s found.".yellow
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
  user_choice = ""
  user_choice = end_prompt(user_choice) # Allow user either to play again or to close program
  if user_choice == "\e"
    puts "Goodbye!"
    exit 0
  end
end
