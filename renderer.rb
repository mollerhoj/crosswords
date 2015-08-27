class Renderer
  def render_crossword
    CROSSWORD.each_with_index do |row,y|
      row.each_with_index do |cell,x|
        print CROSSWORD[y][x].gsub('?',' ')
      end
      puts 
    end
  end
end
