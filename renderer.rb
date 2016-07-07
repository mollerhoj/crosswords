class Renderer
  def render_crossword(crossword)
    @canvas = ""
    crossword.each_with_index do |row,y|
      row.each_with_index do |cell,x|
        @canvas += crossword[y][x].gsub('?',' ')
      end
      @canvas += "\n"
    end
    @canvas
  end

  def clear_lines(lines)
    puts "\e[#{lines + 1}A"
  end
end
