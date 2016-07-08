require_relative 'word_smith'
require_relative 'word_juggler'
require_relative 'renderer'

class Solver
  attr_accessor :options

  def initialize(options = {})
    @options = {
      print_progress: false,
      generate_big_words: true,
      generate_small_words: true 
    }.merge(options)
  end

  def setup
    crossword = [ %w(. . . .),
                  %w(. . ? .),
                  %w(. . . .) ]

    @word_smith = WordSmith.new(@options)
    @word_juggler = WordJuggler.new(crossword,@options)
    self
  end

  def solve
    word_map = @word_smith.load_words
    @word_juggler.set_word_map(word_map)
    return @word_juggler.solve
  end

  def solve_print_progress
    word_map = @word_smith.load_words
    @word_juggler.set_word_map(word_map)
    return @word_juggler.solve_print_progress
  end
end
