require_relative 'solver'

class SolverSpec
  def test_simple_run
    expected = "bagi\nab b\nisac\n"
    Solver.new.setup.solve == expected
  end

  def all_tests
    test_simple_run
  end

  def run
    all_tests ? "success" : "failure"
  end
end

puts SolverSpec.new.run
