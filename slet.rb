File.open('danish_formatted.txt') do |f|
  f.each_line do |line|
    if ((rand*100).to_i) > 90
      puts line
    end
  end
end
