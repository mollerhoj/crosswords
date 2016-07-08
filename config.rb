class Config
  attr_reader :options

  def initialize(options = {})
    @options = default_options.merge(options)
  end

  def default_options
    {
      print_progress: true,
      generate_big_words: true,
      generate_small_words: true,
      double_a_allowed: false,
      ae_allowed: false,
      small_word_size: 5,
      big_word_size: 7,
      words_file: 'danish_test_set_39038.txt',
      letters: %w(a b c d e f g h i j k l m n o p q r s t u v w x y z æ ø å) 
    }
  end
end
