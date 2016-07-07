class Renderer
  def render_crossword(crossword)
    crossword.each_with_index do |row,y|
      row.each_with_index do |cell,x|
        print crossword[y][x].gsub('?',' ')
      end
      puts 
    end
  end

  def clear_lines(lines)
    puts "\e[#{lines + 1}A"
  end
end
