require_relative 'word_smith'

class WordSmithSpec
  def test_load_datastructures
    word_smith = WordSmith.new({print_progress: false, words_file: 'danish_test_set_4383.txt'})
    word_map = word_smith.load_words
    word_map[:small_words].size == 3084 && word_map[:big_words].size == 298
  end

  def test_generate_small_words_data_structure
    word_smith = WordSmith.new({generate_small_words: true, print_progress: false, words_file: 'danish_test_set_4383.txt'})
    word_map = word_smith.load_words
    word_map[:small_words].size == 3084
  end

  def test_generate_big_words_data_structure
    word_smith = WordSmith.new({generate_big_words: true, print_progress: false, words_file: 'danish_test_set_4383.txt'})
    word_map = word_smith.load_words
    word_map[:big_words].size == 298
  end

  def all_tests
    test_load_datastructures &&
    test_generate_big_words_data_structure &&
    test_generate_small_words_data_structure
  end

  def run
    all_tests ? "success" : "failure"
  end
end

puts WordSmithSpec.new.run
