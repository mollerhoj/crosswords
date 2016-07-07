require_relative 'word_smith'

class WordSmithSpec
  def test_simple_run
    expected = "bagi\nab b\nisac\n"
    word_smith = WordSmith.new({
      generate_big_words: @generate_big_words,
      generate_data_structure: @generate_data_structure,
      double_a_allowed: @double_a_allowed,
      ae_allowed: @ae_allowed,
      small_word_size: @small_word_size,
      big_word_size: @big_word_size,
      letters: @letters
    })
    puts word_smith.load_words
    false
  end

  def all_tests
    test_simple_run
  end

  def run
    all_tests ? "success" : "failure"
  end
end

puts WordSmithSpec.new.run
