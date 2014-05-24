def word_init
  # Initialize word bank and choose random word
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
  puts "Are you sure you want to guess a word? ".yellow +
      "You will lose the game if it is wrong. ".yellow
  puts "Press ".yellow + "<enter>".cyan + " to confirm,".yellow +
  " or press any other letter to go back and guess again.".yellow
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
