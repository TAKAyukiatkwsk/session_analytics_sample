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
  p nodes
  nodes.select do |n|
    !n.is_eos? \
    && n.feature.split(',')[0] == '名詞' \
    && n.feature.split(',')[1] != '非自立'
  end
end

data = read_data(ENV['DATA_PATH'])
parsed_data = data.map { |d| parse_with_mecab(nm, d) }
unigram_list = parsed_data.map do |pd|
  unigram(pd.map(&:surface))
end
puts Hash[count_by_group(unigram_list.flatten)]

bigram_list = parsed_data.map do |pd|
  bigram(pd.map(&:surface))
end
puts Hash[count_by_group(bigram_list.flatten)]
