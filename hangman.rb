#!/usr/bin/env ruby

require 'random-word'
require 'io/console'
require 'colorize'
require 'csv'
require 'pry'
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
      "Press ".yellow + "<enter>".cyan + " to confirm or any other letter ".yellow +
      "to go back and guess again.".yellow
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
    return false
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

def update_record(stats)
  File.open("Hangman Statistics.csv", 'w') do |row|
    row.puts "Total,Wins,Losses"
    row.puts "#{stats["Games"]},#{stats["Wins"]},#{stats["Losses"]}"
  end
end

#===================================================================================

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
