# TODO
#
# ____refactoring___
# options should be a global shared object
# Word smith: Write unit tests for generation
# Word smith: Divide into smaller methods
#
# cache bestletter + possible_letters
# Remove words if they contain letters not from @options.letters

#
# This class contains the core algorithm
#

class WordJuggler
  def initialize(crossword, options = {})
    @options = default_options.merge(options)
    @crossword = crossword
    @tried = Array.new(dim_y) { Array.new(dim_x) {Array.new} }
    @last = []
    @last_depth = 0
  end

  def default_options
    { 
      small_word_size: 5,
      letters: %w(a b c d e f g h i j k l m n o p q r s t u v w x y z æ ø å)
    }
  end

  # The word map must be set before the algorithm can run
  def set_word_map(word_map)
    @word_map = word_map
  end

  def dim_y
    @dim_y ||= @crossword.size
  end

  def dim_x
    @dim_x ||= @crossword[0].size
  end

  def possible_words(word, letter, letter_position, maximum)
    possibilities = 0

    if word.length <= @options[:small_word_size]
      possibilities = @word_map[:small_words][word]
      possibilities = 0 if possibilities == nil
    else
      big_word_collection = @word_map[:big_words]["#{word.length}#{letter}#{letter_position}"]
      unless big_word_collection == nil
        big_word_collection.each do |w|
          if w.match Regexp.new word
            possibilities +=1
          end
          if possibilities > maximum
            break
          end
        end
      end
    end

    return possibilities
  end

  def best_letter_and_possibility(x,y,lowest_possible_letters)
    best_letter = 'x'
    possible_letters = 0
    p_max = 0

    horizontal_word = horizontal_word(x,y)
    vertical_word = vertical_word(x,y) 
    offsetH = horizontal_word_start_position(x,y)[0]
    offsetV = vertical_word_start_position(x,y)[1]

    letters = @options[:letters] - (@tried[y][x].map(&:first))

    letters.each do |letter|
      horizontal_word[x-offsetH] = letter
      vertical_word[y-offsetV] = letter

      pH = possible_words(horizontal_word, letter, x-offsetH, lowest_possible_letters)
      pV = possible_words(vertical_word, letter, y-offsetV, lowest_possible_letters)

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
    return [] if x < 0 || x >= dim_x || y < 0 || y >= dim_y || @crossword[y][x] == '?'

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
      word += @crossword[y][x]
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
      word += @crossword[y][x]
    end
    word
  end

  def calc_possibilities
    lowest_possible_letters = Float::INFINITY
    lowest_cell = nil
    lowest_letter = 'z'
    completed = true
    zero_possibilities = false

    @crossword.each_with_index do |row,y|
      row.each_with_index do |cell,x|
        if !zero_possibilities
          if @crossword[y][x] == '.'
            completed = false
            letter, possible_letters = best_letter_and_possibility(x,y,lowest_possible_letters)

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

    if completed
      return false
    end

    if zero_possibilities
      last = @last.pop
      @tried[last[:y]][last[:x]] << [last[:letter], @last_depth]
      @crossword[last[:y]][last[:x]] = '.'

      @tried.each_with_index do |row,y|
        row.each_with_index do |cell,x|
          @tried[y][x].each_with_index do |entry,index|
            if entry[1] == @last_depth + 1
              @tried[y][x].delete_at(index)
            end
          end
        end
      end

      @last_depth -= 1
    else
      @crossword[lowest_cell[1]][lowest_cell[0]] = lowest_letter
      @last.push({ x: lowest_cell[0], y: lowest_cell[1], letter: lowest_letter})
      @last_depth += 1
    end

    return true
  end

  def solve()
    while calc_possibilities; end
    ::Renderer.new.render_crossword(@crossword)
  end

  def solve_print_progress
    dim_y.times do
      puts ""
    end

    # print to console
    while true
     break unless calc_possibilities
     ::Renderer.new.clear_lines(dim_y)
     puts ::Renderer.new.render_crossword(@crossword)
    end

    return ::Renderer.new.render_crossword(@crossword)
  end
end
