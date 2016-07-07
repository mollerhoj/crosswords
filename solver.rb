require_relative 'word_smith'
require_relative 'word_juggler'
require_relative 'renderer'

class Solver
  def initialize
    set_default_options
  end

  attr_accessor :generate_big_words
  attr_accessor :generate_data_structure
  attr_accessor :double_a_allowed
  attr_accessor :ae_allowed
  attr_accessor :small_word_size
  attr_accessor :big_word_size
  attr_accessor :letters
  attr_accessor :crossword

  def set_default_options
    @generate_big_words = false
    @generate_data_structure = false
    @double_a_allowed = false
    @ae_allowed = false
    @small_word_size = 5
    @big_word_size = 7
    @letters = %w(a b c d e f g h i j k l m n o p q r s t u v w x y z æ ø å) 
    @crossword = [ %w(. . . .),
                   %w(. . ? .),
                   %w(. . . .) ]
  end

  def setup
    setup_word_smith
    setup_word_juggler
    self
  end

  def setup_word_smith
    @word_smith = WordSmith.new({
      generate_big_words: @generate_big_words,
      generate_data_structure: @generate_data_structure,
      double_a_allowed: @double_a_allowed,
      ae_allowed: @ae_allowed,
      small_word_size: @small_word_size,
      big_word_size: @big_word_size,
      letters: @letters
    })
  end

  def setup_word_juggler
    @word_juggler = WordJuggler.new(
      @crossword,
      { 
        small_word_size: @small_word_size,
        letters: @letters
      }
    )
  end

  def solve
    @word_smith.load_words
    return @word_juggler.solve
  end
end
