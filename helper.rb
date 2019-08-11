# frozen_string_literal: true

module Helper
  def unigram(word_list)
    word_list
  end

  def bigram(word_list)
    result = []
    length = word_list.length
    word_list.each_with_index do |word, index|
      result << word + word_list[index + 1] if index < length - 1
    end
    result
  end

  def count_by_group(list)
    list.group_by(&:itself)
        .map { |k, v| [k, v.size] }
        .sort { |a, b| b[1] <=> a[1] }
  end
end
