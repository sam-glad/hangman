#!/usr/bin/env ruby

require 'random-word'
require 'io/console'
require 'colorize'
require 'csv'
require './gallows.rb'
require './hangman_methods.rb'


puts "Welcome to Hangman\n\n\n"

if !File.exist?("Hangman Statistics.csv")
  stats = {
  "Games" => 0,
  "Wins" => 0,
  "Losses" => 0
  }

  update_record(stats)
end

# TODO Read in games, wins, losses, ratio
CSV.foreach("Hangman Statistics.csv", headers: true) do |row|
  games = row["Total"] # FIXME Does not work; why?!
  wins = row["Wins"]
  losses = row["Losses"]
  stats = {"Games" => games, "Wins" => wins, "Losses" => losses}
end

puts "     ---=Stats=---"
puts "Total number of games: #{stats["Games"]}"
puts "Wins: #{stats["Wins"]}"
puts "Losses: #{stats["Losses"]}"
puts "\n\n"

user_choice = "\r"

stats["Wins"] = stats["Wins"].to_i
stats["Losses"] = stats["Losses"].to_i
stats["Games"] = stats["Games"].to_i

while user_choice == "\r"
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
    # TODO print stats
    prompt_player(letters_guessed, player_word, chances_left)
    guess = gets.chomp.downcase
    guess = check_input(guess)
    if guess.length > 1 # If user guesses a word; TODO MAKE ALL THIS A NEW LITTLE METHOD
      word_confirmation = confirm_word_entry
      if word_confirmation == "\r"
        if !word_check(guess, hidden, chances_left, chances_total)
          stats["Losses"] += 1
          stats["Games"] += 1
          break
        end
      else
        print_gallows(chances_left, chances_total)
      end
    else # If user guesses a letter
      if !letters_guessed.include?(guess)
        letters_guessed << guess
        if hidden.include?(guess) # If guessed letter is in word
          update_word(guess, hidden, player_word)
          print_gallows(chances_left, chances_total)
          if check_for_win(player_word, hidden)
            stats["Wins"] += 1
            stats["Games"] += 1
          end
        else # If guessed letter is not in word
          chances_left -= 1
          puts "\nSorry, no ".yellow + "#{guess}".cyan + "'s found.".yellow
          print_gallows(chances_left, chances_total)
          if chances_left == 0
            no_chances(hidden)
            stats["Losses"] += 1
            stats["Games"] += 1
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
    update_record(stats)
    exit 0
  end
end
