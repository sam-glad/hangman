#!/usr/bin/env ruby

require 'random-word'

def prompt_player(arr, player_word, chances)
  puts "Word: #{player_word}"
  puts "Chances remaining: #{chances}"
  print "Letters guessed: "
  print_arr(arr)
  print "\nGuess a single letter (a-z) or the entire word: "
end

def word_check(word, str)
  if check_for_win(word, str)
  else
    puts "Sorry, that is not the correct word. Better luck next time..."
    puts "The word was: #{str}"
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
  puts "Found #{times_found} occurrence(s) of the character #{guess}.\n\n"
end

def check_for_win(player_word, hidden)
  if player_word == hidden
    puts "\nCongratulations, you've correctly guessed the word \"#{hidden}\"!"
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

# FIXME busted?
def check_input(str) # This comes after guess = gets.chomp.downcase
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

#==============================================================================

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
chances = hidden.length + 2 # TODO should this be sth else? Important for gameplay, not for overall funvtion
while player_word != hidden
  prompt_player(letters_guessed, player_word, chances)
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
        check_for_win(player_word, hidden)
      else # If guessed letter is not in word
        chances -= 1
        puts "\nSorry, no #{guess}'s found."
        if chances == 0
          no_chances(hidden)
          break
        end
      end
    else
      puts "You already used that letter!\n\n"
    end
  end
end

puts "\nPress <enter> to exit."
gets
