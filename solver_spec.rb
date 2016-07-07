require_relative 'solver'

Solver.new.solve

crossword = [ %w(. . . . .),
              %w(. . . . ?),
              %w(. . . . .),
              %w(. . . ? .),
              %w(. ? . . .) ]

# TODO: Eliminate global variables
# Remove words if they contain letters not from @options.letters
