require 'Nokogiri'

@doc = Nokogiri::HTML::DocumentFragment.parse ""

@crossword = [ ['Person', 'Spy', 'Snake', 'Furniture', 'Movie title', 'Killer robot'],
               ['Animal', nil, nil, nil, nil, nil],
               ['Woman', nil, nil, ['Naked cow', 'Dancer'], nil, nil],
               ['Cake', nil, nil, nil, nil, nil],
               ['Thing', nil, nil, nil, nil, nil] ]

style = """
td {
  border: 1px solid black;
  width: 70px;
  height: 70px;
}
"""

Nokogiri::HTML::Builder.with(@doc) do |doc|
    doc.head {
      doc.style style
    }
    doc.body {
      doc.table {
        @crossword.each do |row|
          doc.tr {
            row.each do |cell|
              if cell.is_a?(Array)
                doc.td {
                  doc.span cell[0]
                  doc.hr
                  doc.span cell[1]
                }
              else
                doc.td cell
              end
            end
          }
        end
      }
    }
end

File.open('table.html', 'w') do |file|
  file.write(@doc.to_html)
end
