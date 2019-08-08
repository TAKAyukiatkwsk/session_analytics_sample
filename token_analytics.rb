# frozen_string_literal: true

require 'CSV'
require 'google/cloud/language'

language = Google::Cloud::Language.new

def read_data(path)
  documents = []
  CSV.foreach(path, headers: true) do |row|
    documents << row[1]
  end
  documents
end

def analyze_syntax(lang_client, text)
  response = lang_client
             .analyze_syntax(content: text, type: :PLAIN_TEXT, language: 'ja')
  response.tokens
          .select { |token| token.part_of_speech.tag == :NOUN }
          .map { |token| token.text.content }
end

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

data = read_data(ENV['DATA_PATH'])
analyzed_data = data.map { |d| analyze_syntax(language, d) }

unigram_list = analyzed_data.map { |ad| unigram(ad) }
puts Hash[count_by_group(unigram_list.flatten)]

bigram_list = analyzed_data.map { |ad| bigram(ad) }
puts Hash[count_by_group(bigram_list.flatten)]
