require'CSV'
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
  nodes.select {|n| !n.is_eos? && n.feature.split(",")[0] == "名詞" }
end

data = read_data(ENV['DATA_PATH'])
parsed = data.map {|d| parse_with_mecab(nm, d) }.flatten
parsed.each {|n| puts n.surface}
