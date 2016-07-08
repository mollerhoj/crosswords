require_relative 'word_smith'
require_relative 'word_juggler'
require_relative 'renderer'
require_relative 'config'

class Solver
  def initialize(options = {})
    @config = Config.new(options)
  end

  def setup
    crossword = [ %w(. . . .),
                  %w(. . ? .),
                  %w(. . . .) ]

    options = @config.options
    @word_smith = WordSmith.new(options)
    @word_juggler = WordJuggler.new(crossword, options)
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
