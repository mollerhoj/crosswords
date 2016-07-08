require_relative 'solver'

class SolverSpec
  def test_simple_run
    expected = "edle\nor v\nfæle\n"
    Solver.new({}).setup.solve == expected
  end

  def test_print_progress
    Solver.new.setup.solve_print_progress
  end

  def all_tests
    test_simple_run &&
    test_print_progress
  end

  def run
    all_tests ? "success" : "failure"
  end
end

puts SolverSpec.new.run
