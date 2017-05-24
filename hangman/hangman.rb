Struct.new('HangmanGame', :word, :score, :hits, :misses)

def generate_hangman_ascii()
  hangman_ascii = File.open("hangman_state", 'r')
  hangman_state = []
  a = 0
  hangman_ascii.each_with_index do |line,i|
    a += 1 if i % 8 == 0 unless i == 0
    hangman_state[a] ||= ''
    hangman_state[a] += line
  end
  hangman_state
end

def fill_blanks(letters, word)
  blank = ''
  word.split('').each do |x|
    if letters.include? x
      blank += x
    else
      blank += '_'
    end
  end
  blank
end

def save_game(game)
  File.open('game', 'w+') { |f| Marshal.dump(game, f) }
end

def open_game(game)
  begin
    File.open('game', 'r+') { |f| game = Marshal.load(f) }
    game
  rescue
    puts "No save exists"
  end
end

game = Struct::HangmanGame.new('', 0, '', '')

dictionary_file = File.open("5desk.txt", 'r')
dictionary = []
dictionary_file.each {|x| dictionary << x.chomp if x.chomp.length > 4 && x.chomp.length < 12}
hangman_state = generate_hangman_ascii

game.word = dictionary[rand(0..dictionary.size-1)].downcase
blanks = '_' * game.word.length

while game.hits.length < game.word.length && game.score < 6
  system 'clear'
  puts hangman_state[game.score]
  puts blanks
  puts game.misses
  print 'Guess: '
  letter = gets.chomp.downcase
  if letter.length == 1 and letter =~ /[a-z]/
    if game.word.include? letter and not game.hits.include? letter
      game.hits += letter * (game.word.count("\\^#{letter}"))
    elsif not game.hits.include? letter
      game.score += 1
      game.misses += letter
    end
  elsif letter == 'save'
    save_game(game)
  elsif letter == 'open'
    game = open_game(game)
  elsif letter == 'quit'
    exit
  end
  blanks = fill_blanks(game.hits,game.word)
end

puts game.word
