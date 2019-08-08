require 'CSV'
require 'natto'

nm = Natto::MeCab.new

def read_data(path)
  documents = []
  CSV.foreach(path, headers: true) do |row|
    documents << row[1]
  end
  documents
end

def parse_with_mecab(nm, text)
  nodes = nm.enum_parse(text).to_a
  p nodes
  nodes.select {|n| !n.is_eos? && n.feature.split(",")[0] == "名詞" && n.feature.split(",")[1] != "非自立"}
end

def unigram(word_list)
  word_list
end

def bigram(word_list)
  result = []
  length = word_list.length
  word_list.each_with_index do |word, index|
    result << word + word_list[index + 1] if index < length -1
  end
  result
end

def count_by_group(list)
  list.group_by(&:itself).map {|k,v| [k, v.size]}.sort{ |a, b| b[1] <=> a[1] }
end

data = read_data(ENV['DATA_PATH'])
parsed_data = data.map {|d| parse_with_mecab(nm, d) }
unigram_list = parsed_data.map do |pd|
  unigram(pd.map(&:surface))
end
puts Hash[count_by_group(unigram_list.flatten)]

bigram_list = parsed_data.map do |pd|
  bigram(pd.map(&:surface))
end
puts Hash[count_by_group(bigram_list.flatten)]
