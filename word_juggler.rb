require 'benchmark'
require 'msgpack'

# TODO
# refactoring
# cache bestletter + possible_letters

# settings
LETTERS = %w(a b c d e f g h i j k l m n o p q r s t u v w x y z æ ø å) 
DIM_X = 5
DIM_Y = 5
MAX_WORD_SIZE = 5
GENERATE_DATA_STRUCTURE = false
GENERATE_BIG_WORDS = false
CENSORED = []
DOUBLE_A_ALLOWED = false
AE_ALLOWED = false

TRIED = Array.new(DIM_Y) { Array.new(DIM_X) {Array.new} }
BEST_LETTERS = Array.new(DIM_Y) { Array.new(DIM_X,'.') }
POSSIBLE_LETTERS = Array.new(DIM_Y) { Array.new(DIM_X,'.') }

CROSSWORD = [ %w(. . . . .),
              %w(. . . . ?),
              %w(. . . . .),
              %w(. . . ? .),
              %w(. ? . . .) ]

UNFILLED = []

# {
#   position: [x,y]
#   letter: 'a'
#   possibility: 4
# }

$last_xs = []
$last_ys = []
$last_letters = []
$depth = 0

class WordJuggler
  def best_letter_and_possibility(x,y,lowest_possible_letters)
    best_letter = 'x'
    possible_letters = 0
    p_max = 0

    horizontal_word = horizontal_word(x,y)
    vertical_word = vertical_word(x,y) 
    offsetH = horizontal_word_start_position(x,y)[0]
    offsetV = vertical_word_start_position(x,y)[1]

    letters = LETTERS - (TRIED[y][x].map(&:first))

    letters.each do |letter|

      horizontal_word[x-offsetH] = letter
      vertical_word[y-offsetV] = letter

      # data structure
      if horizontal_word.length <= MAX_WORD_SIZE
        pH = $word_hash[horizontal_word]
      else
        horizontal_word = Regexp.new horizontal_word
        if $big_word_hash["#{horizontal_word.length}#{letter}#{x-offsetH}"] == nil
          pH = 0
        else
          pH = 0
          $big_word_hash["#{horizontal_word.length}#{letter}#{x-offsetH}"].each do |w|
            if w.match horizontal_word
              pH +=1
            end
            if pH > lowest_possible_letters
              break
            end
          end
        end
      end

      if vertical_word.length <= MAX_WORD_SIZE
        pV = $word_hash[vertical_word]
      else
        vertical_word = Regexp.new vertical_word
        if $big_word_hash["#{vertical_word.length}#{letter}#{y-offsetV}"] == nil
          pV = 0
        else
          pV = 0
          $big_word_hash["#{vertical_word.length}#{letter}#{y-offsetV}"].each do |w|
            if w.match vertical_word
              pV += 1
            end
            if pV > lowest_possible_letters
              break
            end
          end
        end
      end

      pH = 0 if pH == nil
      pV = 0 if pV == nil

      p = [pH,pV].min

      if p > 0
        possible_letters += 1

        if p > p_max
          p_max = p
          best_letter = letter
        end
      end
    end

    return [best_letter, possible_letters]
  end

  def dependent_cells(x,y,dx,dy)
    return [] if x < 0 || x >= DIM_X || y < 0 || y >= DIM_Y || CROSSWORD[y][x] == '?'

    if dx+dy > 0
      [[x,y]] + dependent_cells(x+dx,y+dy,dx,dy)
    else
      dependent_cells(x+dx,y+dy,dx,dy) + [[x,y]]
    end
  end

  def horizontal_dependent_cells(x,y)
    dependent_cells(x,y,-1,0) + dependent_cells(x+1,y,1,0)
  end

  def vertical_dependent_cells(x,y)
    dependent_cells(x,y,0,-1) + dependent_cells(x,y+1,0,1)
  end

  def horizontal_word(x,y)
    word = ''
    horizontal_dependent_cells(x,y).each do |x,y|
      word += CROSSWORD[y][x]
    end
    word
  end

  def horizontal_word_start_position(x,y)
    horizontal_dependent_cells(x,y).first
  end

  def vertical_word_start_position(x,y)
    vertical_dependent_cells(x,y).first
  end

  def vertical_word(x,y)
    word = ''
    vertical_dependent_cells(x,y).each do |x,y|
      word += CROSSWORD[y][x]
    end
    word
  end

  def calc_possibilities
    lowest_possible_letters = 999999
    lowest_cell = nil
    lowest_letter = 'z'
    completed = true
    zero_possibilities = false

    CROSSWORD.each_with_index do |row,y|
      row.each_with_index do |cell,x|
        if !zero_possibilities
          if CROSSWORD[y][x] == '.'
            completed = false
            letter, possible_letters = best_letter_and_possibility(x,y,lowest_possible_letters)

            UNFILLED << {x: x, y: y, letter: letter, posibility: possible_letters}

            if possible_letters == 0
              zero_possibilities = true
            end

            if possible_letters < lowest_possible_letters
              lowest_possible_letters = possible_letters
              lowest_cell = [x,y]
              lowest_letter = letter
            end
          end
        end
      end
    end

    puts UNFILLED.inspect

    if completed
      return false
    end

    if zero_possibilities
      last_y = $last_ys.pop
      last_x = $last_xs.pop
      last_letter = $last_letters.pop

      TRIED[last_y][last_x] << [last_letter, $depth]
      CROSSWORD[last_y][last_x] = '.'

      TRIED.each_with_index do |row,y|
        row.each_with_index do |cell,x|
          TRIED[y][x].each_with_index do |entry,index|
            if entry[1] == $depth + 1
              TRIED[y][x].delete_at(index)
            end
          end
        end
      end

      $depth -= 1
    else
      CROSSWORD[lowest_cell[1]][lowest_cell[0]] = lowest_letter
      $last_ys.push lowest_cell[1]
      $last_xs.push lowest_cell[0]
      $last_letters.push lowest_letter
      $depth += 1
    end

    return true
  end

  def solve
    puts "starting.."

    DIM_Y.times do
      puts ""
    end

    Benchmark.bm do |x|
      x.report do




        while true
         unless calc_possibilities()
           break
         end
         puts "\e[#{DIM_Y + 1}A"
         ::Renderer.new.render_crossword()
       end
      end
    end
  end
end

# solution = [["g", "i", "l", "d", "a"], ["e", "l", "i", "a", "?"], ["m", "a", "n", "g", "e"], ["a", "s", "a", "?", "a"], ["k", "?", "s", "a", "s"]]
# 
# if CROSSWORD != solution
#   puts "\e[#{DIM_Y}A"
#   puts "FAIL                 "
#   puts "FAIL                 "
#   puts "FAIL                 "
#   puts "FAIL                 "
#   puts "FAIL                 "
#   puts "FAIL                 "
#   puts "FAIL                 "
#   puts "FAIL                 "
#   puts "FAIL                 "
#   puts "FAIL                 "
#   puts "FAIL                 "
#   puts "FAIL                 "
#   puts "FAIL                 "
#   puts "FAIL                 "
#   puts "FAIL                 "
#   puts "FAIL                 "
#   puts "FAIL                 "
#   puts "FAIL                 "
#   puts "FAIL                 "
#   raise "FAIL!!!" 
# end
