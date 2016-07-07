require_relative 'word_smith'
require_relative 'word_juggler'
require_relative 'renderer'

class Solver
  def initialize

    small_word_size = 5
    big_word_size = 7
    letters = %w(a b c d e f g h i j k l m n o p q r s t u v w x y z æ ø å) 

    crossword = [ %w(. . . . . .),
                  %w(. . ? . . .),
                  %w(. . . . . .),
                  %w(. . . . . .),
                  %w(. . . . . .) ]

    @word_smith = WordSmith.new({
      generate_big_words: false,
      generate_data_structure: false,
      double_a_allowed: false,
      ae_allowed: false,
      small_word_size: small_word_size,
      big_word_size: big_word_size,
      letters: letters
    })

    @word_juggler = WordJuggler.new(
      crossword,
      { 
        small_word_size: small_word_size,
        letters: letters
      }
    )
  end

  def solve
    @word_smith.load_words
    @word_juggler.solve
  end
end
