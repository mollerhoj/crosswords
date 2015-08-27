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

$last_xs = []
$last_ys = []
$last_letters = []
$depth = 0

### Data structure

require_relative 'word_smith'

def best_letter_and_possibility(regexpH_str,regexpV_str,x,y,offsetH,offsetV,lowest_possible_letters)
  best_letter = 'x'
  possible_letters = 0
  p_max = 0
  possible_letters_list = []

  regexpH = regexpH_str
  regexpV = regexpV_str

  letters = LETTERS - (TRIED[y][x].map(&:first))

  letters.each do |letter|

    regexpH_str[x-offsetH] = letter
    regexpV_str[y-offsetV] = letter

    # data structure
    if regexpH_str.length <= MAX_WORD_SIZE
      pH = $word_hash[regexpH_str]
    else
      regexpH = Regexp.new regexpH_str
      if $big_word_hash["#{regexpH_str.length}#{letter}#{x-offsetH}"] == nil
        pH = 0
      else
        pH = 0
        $big_word_hash["#{regexpH_str.length}#{letter}#{x-offsetH}"].each do |w|
          if w.match regexpH
            pH +=1
          end
          if pH > lowest_possible_letters
            break
          end
        end
      end
    end

    if regexpV_str.length <= MAX_WORD_SIZE
      pV = $word_hash[regexpV_str]
    else
      regexpV = Regexp.new regexpV_str
      if $big_word_hash["#{regexpV_str.length}#{letter}#{y-offsetV}"] == nil
        pV = 0
      else
        pV = 0
        $big_word_hash["#{regexpV_str.length}#{letter}#{y-offsetV}"].each do |w|
          if w.match regexpV
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
      possible_letters_list << [letter, p]

      if p > p_max
        p_max = p
        best_letter = letter
      end
    end
  end

  return [best_letter, possible_letters]
end

def find_deps(x,y)
    depsH2 = []
    depsV2 = []
    offsetH = 0
    offsetV = 0
    #left
    pos_x = x
    loop do
      if pos_x < 0 || CROSSWORD[y][pos_x] == '?'
        offsetH = pos_x+1
        break
      else
        depsH2 << CROSSWORD[y][pos_x]   
      end
      pos_x -= 1
    end
    depsH2 = depsH2.reverse

    #right
    pos_x = x+1
    loop do
      if pos_x >= DIM_X || CROSSWORD[y][pos_x] == '?'
        break
      else
        depsH2 << CROSSWORD[y][pos_x]   
      end
      pos_x += 1
    end

    #up
    pos_y = y
    loop do
      if pos_y < 0 || CROSSWORD[pos_y][x] == '?'
        offsetV = pos_y+1
        break
      else
        depsV2 << CROSSWORD[pos_y][x]
      end
      pos_y -= 1
    end
    depsV2 = depsV2.reverse

    #down
    pos_y = y+1
    loop do
      if pos_y >= DIM_Y || CROSSWORD[pos_y][x] == '?'
        break
      else
        depsV2 << CROSSWORD[pos_y][x]   
      end
      pos_y += 1
    end

    return [depsH2, depsV2, offsetH, offsetV]
end

def calc_possibilities
  lowest_possible_letters = 999999
  lowest_cell = nil
  lowest_letter = 'z'
  finished = true
  failed = false
  CROSSWORD.each_with_index do |row,y|
    row.each_with_index do |cell,x|
      if !failed
        depsH, depsV, offsetH, offsetV = find_deps(x,y)
        if CROSSWORD[y][x] == '.'
          finished = false
          regexpH_str = depsH.join('')
          regexpV_str = depsV.join('')
          letter, possible_letters = best_letter_and_possibility(regexpH_str,regexpV_str,x,y,offsetH,offsetV,lowest_possible_letters)

          if possible_letters == 0
            failed = true
            # puts "failed with #{letter} at (#{x},#{y})"
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

  if finished
    return false
  end

  if failed
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

def render_crossword
  CROSSWORD.each_with_index do |row,y|
    row.each_with_index do |cell,x|
      print CROSSWORD[y][x].gsub('?',' ')
    end
    puts 
  end
end

def build
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
       render_crossword()
     end
    end
  end
end

build

solution = [["g", "i", "l", "d", "a"], ["e", "l", "i", "a", "?"], ["m", "a", "n", "g", "e"], ["a", "s", "a", "?", "a"], ["k", "?", "s", "a", "s"]]

if CROSSWORD != solution
  puts "\e[#{DIM_Y}A"
  puts "FAIL                 "
  puts "FAIL                 "
  puts "FAIL                 "
  puts "FAIL                 "
  puts "FAIL                 "
  puts "FAIL                 "
  puts "FAIL                 "
  puts "FAIL                 "
  puts "FAIL                 "
  puts "FAIL                 "
  puts "FAIL                 "
  puts "FAIL                 "
  puts "FAIL                 "
  puts "FAIL                 "
  puts "FAIL                 "
  puts "FAIL                 "
  puts "FAIL                 "
  puts "FAIL                 "
  puts "FAIL                 "
  raise "FAIL!!!" 
end
