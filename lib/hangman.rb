require "yaml"

# create Display Module
module Display
    def display_intro
        <<~HEREDOC
            Welcome to Hangman!

            Select mode to start game.
            [1] Start a new game
            [2] Load a saved game
        HEREDOC
    end
end

# create Game
class Game

    include Display
    def initialize
        @words_array = File.read("google-10000-english-no-swears.txt").split("\n")
    end
    
    # method to select secret word
    def get_secret_word(array)
        word = array.sample
        until word.length > 5 && word.length < 12
            word = array.sample
        end
        word.upcase
    end

    # method to save game in the middle of a game
    def save_game(name, info)
        Dir.mkdir("saved") unless Dir.exist?("saved")
        filename = "saved/#{name}.yaml"
        File.open(filename, "w") do |file|
            file.write(info.to_yaml)
        end
        puts "#{name}.yaml saved."
    end

    # method to select mode at the beginning
    def select_mode
        mode = gets.chomp
        if mode == "1"
            start_new_game
        elsif mode == "2"
            load_saved_game
        else
            puts "Invalid number. Please choose a mode."
            select_mode
        end
    end

    def start_new_game
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
            puts "\nGuess a letter or enter (save) the game: "
            user_guess = gets.chomp.upcase
            
            if user_guess.to_s == "SAVE"
                puts "Enter the name you want to save:"
                name = gets.chomp.downcase
                save_info = Hash.new(0)
                save_info["secret_word"] = secret_word
                save_info["secret_word_letters"] = secret_word_letters
                save_info["used_letters"] = used_letters
                save_info["lives"] = lives
                save_info["answer_letters"] = answer_letters
                save_game(name, save_info)
                puts "Game saved, see you next time."
                exit 1
            elsif user_guess.match?(/[[:alpha:]]/) && !used_letters.include?(user_guess)
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

    # method to load saved game at the beginning
    def load_saved_game
        puts "Here are the saved games:"
        saved_files = Dir.glob("**/*.yaml").map do |file|
            file[(file.index('/') + 1)...(file.index('.'))]
        end
        puts saved_files
        puts "\nEnter one of the names above to start game:"
        select_saved_game = gets.chomp.downcase
        while !saved_files.include?(select_saved_game)
            puts "#{select_saved_game} does not exist. Please select another one:"
            select_saved_game = gets.chomp.downcase
        end
        puts "Loading #{select_saved_game}..."
        selected_file = "/saved/#{select_saved_game}.yaml"
        open_selected_file = File.open(File.join(Dir.pwd, selected_file), 'r')
        load_yaml = YAML.load(open_selected_file)
        open_selected_file.close

        # variables
        secret_word = load_yaml["secret_word"]
        secret_word_letters = load_yaml["secret_word_letters"]
        used_letters = load_yaml["used_letters"]
        lives = load_yaml["lives"]
        answer_letters = load_yaml["answer_letters"]

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
            puts "\nGuess a letter or enter (save) the game: "
            user_guess = gets.chomp.upcase
            if user_guess.to_s == "SAVE"
                puts "Enter the name you want to save:"
                name = gets.chomp.downcase
                while saved_files.include?(name)
                    puts "#{name} already exist, pick another name:"
                    name = gets.chomp.downcase
                end
                File.delete(File.join(Dir.pwd, selected_file))
                save_info = Hash.new(0)
                save_info["secret_word"] = secret_word
                save_info["secret_word_letters"] = secret_word_letters
                save_info["used_letters"] = used_letters
                save_info["lives"] = lives
                save_info["answer_letters"] = answer_letters
                save_game(name, save_info)
                puts "Game saved, see you next time."
                exit 1
            elsif user_guess.match?(/[[:alpha:]]/) && !used_letters.include?(user_guess)
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
            File.delete(File.join(Dir.pwd, selected_file))
        end
    end

    # method for hangman game
    def hangman
        puts display_intro
        select_mode
    end
end

Game.new.hangman