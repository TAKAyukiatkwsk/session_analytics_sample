# frozen_string_literal: true

$LOAD_PATH.push('.')

require 'CSV'
require 'google/cloud/language'
require 'helper'

include Helper

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

data = read_data(ENV['DATA_PATH'])
ngram_mode = ENV['NGRAM_MODE']
analyzed_data = data.map { |d| analyze_syntax(language, d) }

if ngram_mode == 'unigram'
  unigram_list = analyzed_data.map { |ad| unigram(ad) }
  count_by_group(unigram_list.flatten).each do |g|
    CSV { |csv| csv << g }
  end
elsif ngram_mode == 'bigram'
  bigram_list = analyzed_data.map { |ad| bigram(ad) }
  count_by_group(bigram_list.flatten).each do |g|
    CSV { |csv| csv << g }
  end
else
  puts 'please set env NGRAM_MODE=(unigram | bigram)'
end
