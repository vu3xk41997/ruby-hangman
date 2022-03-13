# create Game
class Game

    def initialize
        @words_array = File.read("google-10000-english-no-swears.txt").split("\n")
    end
    
    # method to select secret word
    def get_secret_word(array)
        word = array.sample
        if word.length < 5 || word.length > 12
            get_secret_word(array)
        else
            word
        end
        word.upcase
    end

    # method for hangman game
    def hangman
        secret_word = get_secret_word(@words_array)
        # keep track of the letters in the word
        secret_word_letters = secret_word.split("").uniq
        # keep track of what user have guessed
        used_letters = []

        lives = 10

        # Stop iteration if secret_word_letters.length == 0 or lives == 0
        while secret_word_letters.length > 0 && lives > 0 do
            # letters used
            puts "\nYou have #{lives} lives left and you have used these letters: #{used_letters.join(' ')}"
            # what current word is:
            answer_letters = []
            for i in (0..secret_word.length-1)
                if used_letters.include?(secret_word[i])
                answer_letters << secret_word[i]
                else
                answer_letters << '_'
                end
            end
            puts "The answer: #{answer_letters.join(' ')}"

            # user guess
            puts "\nGuess a letter: "
            user_guess = gets.chomp.upcase
            if user_guess.match?(/[[:alpha:]]/) && !used_letters.include?(user_guess)
                used_letters << user_guess
                if secret_word_letters.include?(user_guess)
                    secret_word_letters.delete(user_guess)
                else
                    lives = lives - 1
                    puts "Letter is not in the word."
                end
            elsif used_letters.include?(user_guess)
                puts "You've used this letter already. Guess another one."
            else
                puts "Invalid letter. Try again."
            end
        end
        if lives == 0
            puts "Sorry you\'re dead. The answer is #{secret_word}..."
        else 
            puts "Yay! You guessed the answer, #{secret_word}!!"
        end
    end
end

Game.new.hangman