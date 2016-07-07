$word_hash = {}
$big_word_hash = {}

# This class loads word from the data files

class WordSmith
  def initialize(options)
    @options = options
  end

  def load_words
    # Loading all words into the all_words array
    if @options[:generate_big_words] || @options[:generate_data_structure]
      all_words = []
      File.open('danish_formatted.txt') do |f|
        f.each_line do |line|
          all_words << line.delete("\n")
        end
      end

      # Remove double aa
      if !@options[:double_a_allowed]
        all_words.delete_if { |w| }.delete_if { |w| w.match 'aa' }
      end
      #
      if !@options[:ae_allowed]
        all_words.delete_if { |w| }.delete_if { |w| w.match 'ae' }
      end
    end

    if @options[:generate_big_words]
      @options[:letters].each do |letter|
        (@options[:small_word_size]+1..@options[:big_word_size]).to_a.each do |i|
          words_of_current_size = all_words.select { |w| w.length == i }
          (0..i-1).each do |j|
            words = words_of_current_size.select { |w| w[j] == letter }
            if words.size > 0
              $big_word_hash["#{i}#{letter}#{j}"] = words
            end
          end
        end
        print letter
      end

      File.open("big_word_hash.msg","w") do |f|
        f.write($big_word_hash.to_msgpack)
      end
    else
      puts "loading big words..."
      $big_word_hash = MessagePack.unpack(File.read('big_word_hash.msg'))
      puts "...big words loaded"
    end

    # # word stats:
    # LETTERS.each do |letter|
    #   puts letter
    #   (1..36).each do |n|
    #     puts "#{n}: #{all_words.select { |w| w.length == n && w[0] == letter }.size}"
    #   end
    # end
    # raise "END"
    #

    Benchmark.bm do |x|
      x.report do
        if @options[:generate_data_structure]
          puts "generating data structure..."
          last_percent = -1
          count = all_words.size 
          all_words.each_with_index do |word,word_index|
            if word.size <= @options[:small_word_size]
              [0,1].repeated_permutation(word.size).each do |permutation|
                key = permutation.each_with_index.map { |n,i| n == 0 ? word[i] : '.' }.join('')
                if $word_hash[key] == nil
                  $word_hash[key] = 1
                else
                  $word_hash[key] += 1
                end
              end
            end
            percent = ((word_index.to_f/count.to_f) * 100).to_i
            if percent > last_percent
              puts "#{percent} of 100 "
              last_percent = percent
            end
          end
          puts "...data structure finished"

          File.open("word_hash.msg","w") do |f|
            f.write($word_hash.to_msgpack)
          end

          puts "data structure saved"
          all_words = nil #gb collect
        else
          puts "loading data structure..."

          $word_hash = MessagePack.unpack(File.read('word_hash.msg'))
          puts "...data structure loaded"
        end
      end
    end
  end
end
