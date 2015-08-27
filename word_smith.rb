$word_hash = {}
$big_word_hash = {}

class WordSmith
  def load_words
    puts "loading all words..."
    if GENERATE_BIG_WORDS || GENERATE_DATA_STRUCTURE
      all_words = []
      File.open('danish2.txt') do |f|
        f.each_line do |line|
          all_words << line.delete("\n")
        end
      end
      if !DOUBLE_A_ALLOWED
        all_words.delete_if { |w| }.delete_if { |w| w.match 'aa' }
      end
      if !AE_ALLOWED
        all_words.delete_if { |w| }.delete_if { |w| w.match 'ae' }
      end
    end

    if GENERATE_BIG_WORDS
      LETTERS.each do |letter|
        (MAX_WORD_SIZE+1..36).to_a.each do |i|
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
        if GENERATE_DATA_STRUCTURE
          puts "generating data structure..."
          last_percent = -1
          count = all_words.size 
          all_words.each_with_index do |word,word_index|
            if word.size <= MAX_WORD_SIZE
              #puts word
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
