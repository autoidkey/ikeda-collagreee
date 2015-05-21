# MeCabの仕様についていろいろ試すファイル。Collagreeのシステムには関係無い。

require 'natto'

text = 'すもももももももものうち'
entry = 'そして１年後に、まず小堺君が「欽ちゃんのどこまでやるの！？」（テレビ朝日系）のレギュラーになり、その後、僕にも声が掛かりました。'

natto = Natto::MeCab.new
natto.parse(entry) do |n|
	# 左が分解した単語、右がその詳細
  puts "#{n.surface}\t#{n.feature}"
end

text2 = 'キーワードの一致判定をします。'

if text == text2
	print "Good!!"
end

# 部分一致のテスト
text3 = 'もの'
pos = text.include?(text3)

print "#{pos}\n"

# 名詞だけ取り出すテスト
def parse_noun(word)  
  # print "version: ", MeCab::VERSION, "\n"     # debug  

  nm = Natto::MeCab.new
  ret = []
  nm.parse(word) do |e|
    if e.feature.include?("名詞")
    	ret << e.surface
    end
  end
  
  return ret  
end  
  
puts parse_noun(entry)  

