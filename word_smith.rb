require 'msgpack'
require_relative 'config'

# This class loads word from the data files

class WordSmith
  def initialize(options = {})
    @options = Config.new(options).options

    @small_words = {}
    @big_words = {}

    @all_words = []
  end

  def load_words
    if @options[:generate_big_words] || @options[:generate_small_words]
      all_words = load_all_words
      all_words = clean_all_words(all_words)
    end

    if @options[:generate_big_words]
      generate_big_words(all_words)
      save_big_words
    else
      load_big_words
    end

    if @options[:generate_small_words]
      generate_small_words(all_words)
      save_small_words
    else
      load_small_words
    end

    return {
      small_words: @small_words,
      big_words: @big_words
    }
  end

  private

  def load_all_words
    all_words = []
    File.open(@options[:words_file]) do |f|
      f.each_line do |line|
        all_words << line.delete("\n")
      end
    end
    all_words
  end

  def clean_all_words(all_words)
    if !@options[:double_a_allowed]
      all_words.delete_if { |w| }.delete_if { |w| w.match 'aa' }
    end

    if !@options[:ae_allowed]
      all_words.delete_if { |w| }.delete_if { |w| w.match 'ae' }
    end
    all_words
  end
  
  def generate_big_words(all_words)
    @options[:letters].each do |letter|
      (@options[:small_word_size]+1..@options[:big_word_size]).to_a.each do |i|
        words_of_current_size = all_words.select { |w| w.length == i }
        (0..i-1).each do |j|
          words = words_of_current_size.select { |w| w[j] == letter }
          if words.size > 0
            @big_words["#{i}#{letter}#{j}"] = words
          end
        end
      end
      conditional_print letter
    end
  end

  def save_big_words
    conditional_puts "saving big words..."
    File.open("big_word_hash.msg","w") do |f|
      f.write(@big_words.to_msgpack)
    end
    conditional_puts "...big words saved"
  end

  def load_big_words
    conditional_puts "loading big words..."
    @big_words = MessagePack.unpack(File.read('big_word_hash.msg'))
    conditional_puts "...big words loaded"
  end

  def generate_small_words(all_words)
    conditional_puts "generating small words data structure..."
    last_percent = -1
    count = all_words.size 
    all_words.each_with_index do |word,word_index|
      if word.size <= @options[:small_word_size]
        [0,1].repeated_permutation(word.size).each do |permutation|
          key = permutation.each_with_index.map { |n,i| n == 0 ? word[i] : '.' }.join('')
          if @small_words[key] == nil
            @small_words[key] = 1
          else
            @small_words[key] += 1
          end
        end
      end
      percent = ((word_index.to_f/count.to_f) * 100).to_i
      if percent > last_percent
        conditional_puts "#{percent} of 100 "
        last_percent = percent
      end
    end
    conditional_puts "...small words data structure generated"
  end

  def save_small_words
    conditional_puts "saving small words data structure..."
    File.open("small_word_hash.msg","w") do |f|
      f.write(@small_words.to_msgpack)
    end
    conditional_puts "...small words data structure saved"
  end

  def load_small_words
    conditional_puts "loading small words data structure..."
    @small_words = MessagePack.unpack(File.read('small_word_hash.msg'))
    conditional_puts "...data small words structure loaded"
  end

  def conditional_print message
    if @options[:print_progress]
      print message
    end
  end

  def conditional_puts message
    if @options[:print_progress]
      puts message
    end
  end
end
