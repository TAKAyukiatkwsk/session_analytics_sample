# frozen_string_literal: true

$LOAD_PATH.push('.')

require 'CSV'
require 'natto'
require 'helper'

include Helper

nm = Natto::MeCab.new

def read_data(path)
  documents = []
  CSV.foreach(path, headers: true) do |row|
    documents << row[1]
  end
  documents
end

def parse_with_mecab(mecab, text)
  nodes = mecab.enum_parse(text).to_a
  nodes.select do |n|
    !n.is_eos? \
    && n.feature.split(',')[0] == '名詞' \
    && n.feature.split(',')[1] != '非自立'
  end
end

data = read_data(ENV['DATA_PATH'])
ngram_mode = ENV['NGRAM_MODE']
parsed_data = data.map { |d| parse_with_mecab(nm, d) }

if ngram_mode == 'unigram'
  unigram_list = parsed_data.map do |pd|
    unigram(pd.map(&:surface))
  end
  count_by_group(unigram_list.flatten).each do |g|
    CSV { |csv| csv << g }
  end
elsif ngram_mode == 'bigram'
  bigram_list = parsed_data.map do |pd|
    bigram(pd.map(&:surface))
  end
  count_by_group(bigram_list.flatten).each do |g|
    CSV { |csv| csv << g }
  end
else
  puts 'please set env NGRAM_MODE=(unigram | bigram)'
end
