require_relative 'word_smith'
require_relative 'word_juggler'
require_relative 'renderer'

class Solver
  def initialize
    @word_smith = WordSmith.new
    @word_juggler = WordJuggler.new
  end

  def solve
    @word_smith.load_words
    @word_juggler.solve
  end
end
