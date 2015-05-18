# MeCabの仕様についていろいろ試すファイル。Collagreeのシステムには関係無い。

require 'natto'

text = 'すもももももももものうち'

natto = Natto::MeCab.new
natto.parse(text) do |n|
	# 左が分解した単語、右がその詳細
  puts "#{n.surface}\t#{n.feature}"
end

text2 = 'すもももももももものうち'

if text == text2
	print "Good!!"
end