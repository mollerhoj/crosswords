require_relative 'solver'

class SolverSpec
  def test_more_big_words
    expected = "edle\nor v\nfæle\n"
    Solver.new({print_progress: false, small_words_size: 3}).setup.solve == expected
  end

  def test_print_progress
    Solver.new({print_progress: false}).setup.solve_print_progress
  end

  def all_tests
    test_more_big_words &&
    test_print_progress 
  end

  def run
    all_tests ? "success" : "failure"
  end
end

puts SolverSpec.new.run
